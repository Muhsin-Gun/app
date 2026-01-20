import 'package:flutter/foundation.dart';

class AppConfig {
  static const bool isProduction = kReleaseMode;
  static const bool enableLogging = !isProduction;
  
  // Firebase Configuration
  static const String firebaseProjectId = 'your-project-id';
  static const String firebaseApiKey = 'your-api-key';
  static const String firebaseAppId = 'your-app-id';
  static const String firebaseMessagingSenderId = 'your-sender-id';
  static const String firebaseStorageBucket = 'your-storage-bucket';
  
  // Google Sign-In Configuration
  static const String googleWebClientId = '419781318218-kui6dsjb3cn0gna1h62tpmd34vckoh0g.apps.googleusercontent.com';
  static const String googleAndroidClientId = 'your-android-client-id.apps.googleusercontent.com';
  static const String googleIosClientId = 'your-ios-client-id.apps.googleusercontent.com';
  
  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'ddwfkeess';
  static const String cloudinaryApiKey = 'your-api-key';
  static const String cloudinaryApiSecret = 'your-api-secret';
  static const String cloudinaryUploadPreset = 'ecommerce';
  
  // App Configuration
  static const String appName = 'ProMarket';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@promarket.com';
  static const String privacyPolicyUrl = 'https://promarket.com/privacy';
  static const String termsOfServiceUrl = 'https://promarket.com/terms';
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  
  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation Configuration
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxMessageLength = 1000;
  
  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  
  // Environment-specific configurations
  static String get baseUrl {
    if (isProduction) {
      return 'https://api.promarket.com';
    } else {
      return 'https://dev-api.promarket.com';
    }
  }
  
  static String get websocketUrl {
    if (isProduction) {
      return 'wss://ws.promarket.com';
    } else {
      return 'wss://dev-ws.promarket.com';
    }
  }
  
  static Map<String, dynamic> get firebaseConfig {
    return {
      'apiKey': firebaseApiKey,
      'appId': firebaseAppId,
      'messagingSenderId': firebaseMessagingSenderId,
      'projectId': firebaseProjectId,
      'storageBucket': firebaseStorageBucket,
    };
  }
  
  static void log(String message) {
    if (enableLogging) {
      print('[${DateTime.now().toIso8601String()}] $message');
    }
  }
  
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      print('[ERROR ${DateTime.now().toIso8601String()}] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
}