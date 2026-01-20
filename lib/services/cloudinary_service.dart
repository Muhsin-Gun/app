import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../core/constants.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Upload image to Cloudinary
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      AppConfig.log('Starting image upload to Cloudinary: $fileName');
      
      final url = Uri.parse(
        '${AppConstants.cloudinaryUploadUrl}/${AppConfig.cloudinaryCloudName}/image/upload'
      );

      final request = http.MultipartRequest('POST', url);
      
      // Add upload preset
      request.fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;
      
      // Add optional parameters
      request.fields['folder'] = 'promarket'; // Organize uploads in folder
      request.fields['resource_type'] = 'image';
      request.fields['format'] = 'auto'; // Auto-optimize format
      request.fields['quality'] = 'auto:good'; // Auto-optimize quality
      
      // Add the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      AppConfig.log('Sending upload request to Cloudinary');
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final data = jsonDecode(responseString);
        
        final secureUrl = data['secure_url'] as String?;
        
        if (secureUrl != null) {
          AppConfig.log('Image uploaded successfully: $secureUrl');
          return secureUrl;
        } else {
          AppConfig.logError('No secure_url in Cloudinary response', data);
          return null;
        }
      } else {
        final errorResponse = await response.stream.bytesToString();
        AppConfig.logError('Cloudinary upload failed with status ${response.statusCode}', errorResponse);
        return null;
      }
    } catch (e) {
      AppConfig.logError('Image upload error', e);
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<Uint8List> imageBytesList, List<String> fileNames) async {
    try {
      AppConfig.log('Uploading ${imageBytesList.length} images to Cloudinary');
      
      final uploadTasks = <Future<String?>>[];
      
      for (int i = 0; i < imageBytesList.length; i++) {
        uploadTasks.add(uploadImage(imageBytesList[i], fileNames[i]));
      }
      
      final results = await Future.wait(uploadTasks);
      final successfulUploads = results.where((url) => url != null).cast<String>().toList();
      
      AppConfig.log('Successfully uploaded ${successfulUploads.length}/${imageBytesList.length} images');
      return successfulUploads;
    } catch (e) {
      AppConfig.logError('Multiple image upload error', e);
      return [];
    }
  }

  // Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      AppConfig.log('Deleting image from Cloudinary: $publicId');
      
      final url = Uri.parse(
        '${AppConstants.cloudinaryUploadUrl}/${AppConfig.cloudinaryCloudName}/image/destroy'
      );

      // Generate timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Create signature for authenticated request
      final signature = _generateSignature(publicId, timestamp);

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': AppConfig.cloudinaryApiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] as String?;
        
        if (result == 'ok') {
          AppConfig.log('Image deleted successfully from Cloudinary');
          return true;
        } else {
          AppConfig.logError('Failed to delete image from Cloudinary', data);
          return false;
        }
      } else {
        AppConfig.logError('Cloudinary delete failed with status ${response.statusCode}', response.body);
        return false;
      }
    } catch (e) {
      AppConfig.logError('Image deletion error', e);
      return false;
    }
  }

  // Generate transformation URL for image optimization
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto:good',
    String format = 'auto',
    String crop = 'fill',
  }) {
    try {
      // Extract public ID from Cloudinary URL
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 3) {
        AppConfig.logError('Invalid Cloudinary URL format', originalUrl);
        return originalUrl;
      }
      
      final cloudName = pathSegments[0];
      final resourceType = pathSegments[1];
      final version = pathSegments[2];
      final publicIdWithExtension = pathSegments.sublist(3).join('/');
      
      // Build transformation parameters
      final transformations = <String>[];
      
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('q_$quality');
      transformations.add('f_$format');
      transformations.add('c_$crop');
      
      final transformationString = transformations.join(',');
      
      // Construct optimized URL
      final optimizedUrl = 'https://res.cloudinary.com/$cloudName/$resourceType/upload/$transformationString/v$version/$publicIdWithExtension';
      
      AppConfig.log('Generated optimized image URL: $optimizedUrl');
      return optimizedUrl;
    } catch (e) {
      AppConfig.logError('Failed to generate optimized image URL', e);
      return originalUrl;
    }
  }

  // Get thumbnail URL
  String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'thumb',
      quality: 'auto:low',
    );
  }

  // Get responsive image URLs for different screen sizes
  Map<String, String> getResponsiveImageUrls(String originalUrl) {
    return {
      'thumbnail': getThumbnailUrl(originalUrl, size: 150),
      'small': getOptimizedImageUrl(originalUrl, width: 400, height: 300),
      'medium': getOptimizedImageUrl(originalUrl, width: 800, height: 600),
      'large': getOptimizedImageUrl(originalUrl, width: 1200, height: 900),
      'original': originalUrl,
    };
  }

  // Extract public ID from Cloudinary URL
  String? extractPublicId(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 4) {
        return null;
      }
      
      // Remove version and get public ID
      final publicIdWithExtension = pathSegments.sublist(3).join('/');
      
      // Remove file extension
      final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
      if (lastDotIndex != -1) {
        return publicIdWithExtension.substring(0, lastDotIndex);
      }
      
      return publicIdWithExtension;
    } catch (e) {
      AppConfig.logError('Failed to extract public ID from URL', e);
      return null;
    }
  }

  // Validate image before upload
  bool validateImage(Uint8List imageBytes, String fileName) {
    try {
      // Check file size (max 5MB)
      if (imageBytes.length > AppConfig.maxImageSizeMB * 1024 * 1024) {
        AppConfig.logError('Image too large', 'Size: ${imageBytes.length} bytes');
        return false;
      }
      
      // Check file extension
      final extension = fileName.split('.').last.toLowerCase();
      if (!AppConfig.allowedImageTypes.contains(extension)) {
        AppConfig.logError('Invalid image type', 'Extension: $extension');
        return false;
      }
      
      return true;
    } catch (e) {
      AppConfig.logError('Image validation error', e);
      return false;
    }
  }

  // Generate signature for authenticated requests
  String _generateSignature(String publicId, int timestamp) {
    // Note: This is a simplified version. In production, you should use
    // a proper HMAC-SHA1 implementation with your API secret
    // For security, signature generation should be done on the server side
    
    final params = 'public_id=$publicId&timestamp=$timestamp${AppConfig.cloudinaryApiSecret}';
    
    // This is a placeholder - implement proper HMAC-SHA1 signature
    // You might want to use a package like 'crypto' for this
    return params.hashCode.toString();
  }

  // Get upload progress (for future implementation with streams)
  Stream<double> uploadImageWithProgress(Uint8List imageBytes, String fileName) async* {
    // This is a placeholder for upload progress tracking
    // In a real implementation, you would use a streaming upload
    // and yield progress values from 0.0 to 1.0
    
    yield 0.0; // Start
    yield 0.3; // Processing
    yield 0.7; // Uploading
    
    final result = await uploadImage(imageBytes, fileName);
    
    if (result != null) {
      yield 1.0; // Complete
    } else {
      yield -1.0; // Error
    }
  }

  // Batch upload with progress tracking
  Stream<Map<String, dynamic>> uploadMultipleImagesWithProgress(
    List<Uint8List> imageBytesList,
    List<String> fileNames,
  ) async* {
    for (int i = 0; i < imageBytesList.length; i++) {
      yield {
        'index': i,
        'fileName': fileNames[i],
        'status': 'uploading',
        'progress': 0.0,
      };
      
      final result = await uploadImage(imageBytesList[i], fileNames[i]);
      
      yield {
        'index': i,
        'fileName': fileNames[i],
        'status': result != null ? 'completed' : 'failed',
        'progress': 1.0,
        'url': result,
      };
    }
  }
}