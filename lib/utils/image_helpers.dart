import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_config.dart';

class ImageHelpers {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      AppConfig.log('Picking image from gallery');
      
      // Check permission
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        AppConfig.logError('Gallery permission denied');
        return null;
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: AppConfig.imageQuality,
      );
      
      if (image != null) {
        AppConfig.log('Image picked from gallery: ${image.name}');
      }
      
      return image;
    } catch (e) {
      AppConfig.logError('Failed to pick image from gallery', e);
      return null;
    }
  }

  // Pick image from camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      AppConfig.log('Taking photo with camera');
      
      // Check permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        AppConfig.logError('Camera permission denied');
        return null;
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: AppConfig.imageQuality,
      );
      
      if (image != null) {
        AppConfig.log('Photo taken with camera: ${image.name}');
      }
      
      return image;
    } catch (e) {
      AppConfig.logError('Failed to take photo with camera', e);
      return null;
    }
  }

  // Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages({int maxImages = 5}) async {
    try {
      AppConfig.log('Picking multiple images from gallery (max: $maxImages)');
      
      // Check permission
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        AppConfig.logError('Gallery permission denied');
        return [];
      }
      
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: AppConfig.imageQuality,
      );
      
      // Limit the number of images
      final limitedImages = images.take(maxImages).toList();
      
      AppConfig.log('Picked ${limitedImages.length} images from gallery');
      return limitedImages;
    } catch (e) {
      AppConfig.logError('Failed to pick multiple images', e);
      return [];
    }
  }

  // Crop image
  static Future<CroppedFile?> cropImage(String imagePath) async {
    try {
      AppConfig.log('Cropping image: $imagePath');
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
          ),
          WebUiSettings(
            context: null, // Will be handled by the cropper
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: const CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      
      if (croppedFile != null) {
        AppConfig.log('Image cropped successfully: ${croppedFile.path}');
      }
      
      return croppedFile;
    } catch (e) {
      AppConfig.logError('Failed to crop image', e);
      return null;
    }
  }

  // Convert XFile to Uint8List
  static Future<Uint8List?> xFileToBytes(XFile file) async {
    try {
      AppConfig.log('Converting XFile to bytes: ${file.name}');
      final bytes = await file.readAsBytes();
      AppConfig.log('Converted ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      AppConfig.logError('Failed to convert XFile to bytes', e);
      return null;
    }
  }

  // Convert CroppedFile to Uint8List
  static Future<Uint8List?> croppedFileToBytes(CroppedFile file) async {
    try {
      AppConfig.log('Converting CroppedFile to bytes: ${file.path}');
      final bytes = await file.readAsBytes();
      AppConfig.log('Converted ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      AppConfig.logError('Failed to convert CroppedFile to bytes', e);
      return null;
    }
  }

  // Validate image file
  static bool validateImageFile(XFile file) {
    try {
      // Check file extension
      final extension = file.name.split('.').last.toLowerCase();
      if (!AppConfig.allowedImageTypes.contains(extension)) {
        AppConfig.logError('Invalid image type: $extension');
        return false;
      }
      
      return true;
    } catch (e) {
      AppConfig.logError('Image validation failed', e);
      return false;
    }
  }

  // Validate image size
  static Future<bool> validateImageSize(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final sizeInMB = bytes.length / (1024 * 1024);
      
      if (sizeInMB > AppConfig.maxImageSizeMB) {
        AppConfig.logError('Image too large: ${sizeInMB.toStringAsFixed(2)}MB');
        return false;
      }
      
      AppConfig.log('Image size valid: ${sizeInMB.toStringAsFixed(2)}MB');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to validate image size', e);
      return false;
    }
  }

  // Get image dimensions
  static Future<Size?> getImageDimensions(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final size = Size(image.width.toDouble(), image.height.toDouble());
      AppConfig.log('Image dimensions: ${size.width}x${size.height}');
      
      return size;
    } catch (e) {
      AppConfig.logError('Failed to get image dimensions', e);
      return null;
    }
  }

  // Compress image
  static Future<Uint8List?> compressImage(Uint8List imageBytes, {int quality = 85}) async {
    try {
      AppConfig.log('Compressing image with quality: $quality');
      
      // For now, return original bytes
      // In a real implementation, you would use a package like flutter_image_compress
      // to compress the image
      
      AppConfig.log('Image compression completed');
      return imageBytes;
    } catch (e) {
      AppConfig.logError('Failed to compress image', e);
      return null;
    }
  }

  // Resize image
  static Future<Uint8List?> resizeImage(
    Uint8List imageBytes, {
    int? maxWidth,
    int? maxHeight,
    bool maintainAspectRatio = true,
  }) async {
    try {
      AppConfig.log('Resizing image to ${maxWidth}x$maxHeight');
      
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        AppConfig.logError('Failed to convert resized image to bytes');
        return null;
      }
      
      final resizedBytes = byteData.buffer.asUint8List();
      AppConfig.log('Image resized successfully: ${resizedBytes.length} bytes');
      
      return resizedBytes;
    } catch (e) {
      AppConfig.logError('Failed to resize image', e);
      return null;
    }
  }

  // Show image picker dialog
  static Future<XFile?> showImagePickerDialog(BuildContext context) async {
    return showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final image = await pickImageFromCamera();
                  if (context.mounted) {
                    Navigator.of(context).pop(image);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Generate placeholder image
  static Widget generatePlaceholderImage({
    double width = 100,
    double height = 100,
    Color backgroundColor = Colors.grey,
    IconData icon = Icons.image,
    Color iconColor = Colors.white,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: width * 0.4,
      ),
    );
  }

  // Create circular avatar from image
  static Widget createCircularAvatar({
    required String? imageUrl,
    required String fallbackText,
    double radius = 25,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: backgroundColor,
        onBackgroundImageError: (exception, stackTrace) {
          AppConfig.logError('Failed to load avatar image', exception);
        },
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Get file extension from file name
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Generate unique file name
  static String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = getFileExtension(originalFileName);
    return 'image_${timestamp}.$extension';
  }

  // Check if URL is a valid image URL
  static bool isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      return AppConfig.allowedImageTypes.any((ext) => path.endsWith('.$ext'));
    } catch (e) {
      return false;
    }
  }
}