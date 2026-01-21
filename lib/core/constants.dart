class AppConstants {
  // App Info
  static const String appName = 'ProMarket';
  static const String appVersion = '1.0.0';
  
  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'ddwfkeess';
  static const String cloudinaryUploadPreset = 'ecommerce';
  static const String cloudinaryApiKey = 'your_api_key';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String bookingsCollection = 'bookings';
  static const String messagesCollection = 'messages';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String clientRole = 'client';
  static const String employeeRole = 'employee';
  
  // Booking Status
  static const String pendingStatus = 'pending';
  static const String assignedStatus = 'assigned';
  static const String activeStatus = 'active';
  static const String completedStatus = 'completed';
  static const String cancelledStatus = 'cancelled';
  
  // Routes
  static const String loginRoute = '/login';
  static const String onboardingRoute = '/onboarding';
  static const String roleSelectorRoute = '/role-selector';
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String clientDashboardRoute = '/client-dashboard';
  static const String employeeDashboardRoute = '/employee-dashboard';
  
  // API Endpoints
  static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxMessageLength = 500;
  static const int maxImageSizeMB = 5;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

class AppStrings {
  // Authentication
  static const String signInWithGoogle = 'Sign in with Google';
  static const String signInWithApple = 'Sign in with Apple';
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue';
  static const String selectYourRole = 'Select Your Role';
  static const String getStarted = 'Get Started';
  
  // Roles
  static const String admin = 'Admin';
  static const String client = 'Client';
  static const String employee = 'Employee';
  static const String adminDescription = 'Manage products, bookings, and employees';
  static const String clientDescription = 'Browse and book services';
  static const String employeeDescription = 'Manage assigned jobs and communicate with clients';
  
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String products = 'Products';
  static const String bookings = 'Bookings';
  static const String messages = 'Messages';
  static const String profile = 'Profile';
  static const String employees = 'Employees';
  static const String browse = 'Browse';
  static const String jobs = 'Jobs';
  
  // Actions
  static const String create = 'Create';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String book = 'Book';
  static const String assign = 'Assign';
  static const String complete = 'Complete';
  static const String send = 'Send';
  static const String upload = 'Upload';
  
  // Status
  static const String pending = 'Pending';
  static const String assigned = 'Assigned';
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  
  // Errors
  static const String errorOccurred = 'An error occurred';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authenticationFailed = 'Authentication failed';
  static const String permissionDenied = 'Permission denied';
  static const String imageUploadFailed = 'Image upload failed';
  static const String invalidInput = 'Invalid input';
  
  // Success Messages
  static const String loginSuccessful = 'Login successful';
  static const String productCreated = 'Product created successfully';
  static const String bookingCreated = 'Booking created successfully';
  static const String statusUpdated = 'Status updated successfully';
  static const String messageSent = 'Message sent';
}
