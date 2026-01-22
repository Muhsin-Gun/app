// App Constants
class AppConstants {
  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'your_cloud_name';
  static const String cloudinaryUploadPreset = 'your_upload_preset';
  
  // API Endpoints
  static const String baseUrl = 'https://api.promarket.com';
  
  // App Settings
  static const int maxImageSize = 800;
  static const int imageQuality = 85;
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}
