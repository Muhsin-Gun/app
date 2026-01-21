import '../core/app_config.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConfig.minPasswordLength) {
      return 'Password must be at least ${AppConfig.minPasswordLength} characters';
    }
    
    if (value.length > AppConfig.maxPasswordLength) {
      return 'Password must be less than ${AppConfig.maxPasswordLength} characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > AppConfig.maxNameLength) {
      return 'Name must be less than ${AppConfig.maxNameLength} characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }
    
    return null;
  }

  // Product title validation
  static String? validateProductTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product title is required';
    }
    
    if (value.trim().length < 3) {
      return 'Product title must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Product title must be less than 100 characters';
    }
    
    return null;
  }

  // Product description validation
  static String? validateProductDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product description is required';
    }
    
    if (value.trim().length < 10) {
      return 'Product description must be at least 10 characters';
    }
    
    if (value.length > AppConfig.maxDescriptionLength) {
      return 'Product description must be less than ${AppConfig.maxDescriptionLength} characters';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    if (price > 999999.99) {
      return 'Price must be less than \$1,000,000';
    }
    
    // Check for maximum 2 decimal places
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Price can have maximum 2 decimal places';
    }
    
    return null;
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    
    if (value.trim().length < 2) {
      return 'Category must be at least 2 characters';
    }
    
    return null;
  }

  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.length > AppConfig.maxMessageLength) {
      return 'Message must be less than ${AppConfig.maxMessageLength} characters';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    
    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }
    
    return null;
  }

  // Notes validation (optional field)
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.length > 500) {
      return 'Notes must be less than 500 characters';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL might be optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'Date cannot be in the past';
    }
    
    // Check if date is too far in the future (e.g., 1 year)
    final oneYearFromNow = now.add(const Duration(days: 365));
    if (value.isAfter(oneYearFromNow)) {
      return 'Date cannot be more than 1 year in the future';
    }
    
    return null;
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }
    
    return null;
  }

  // File size validation
  static String? validateFileSize(int fileSizeBytes, {int maxSizeMB = 5}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    
    if (fileSizeBytes > maxSizeBytes) {
      return 'File size must be less than ${maxSizeMB}MB';
    }
    
    return null;
  }

  // Image file validation
  static String? validateImageFile(String fileName) {
    if (fileName.isEmpty) {
      return 'Please select an image';
    }
    
    final extension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    
    if (!allowedExtensions.contains(extension)) {
      return 'Please select a valid image file (JPG, PNG, WebP, GIF)';
    }
    
    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Search can be empty
    }
    
    if (value.trim().length < 2) {
      return 'Search query must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Search query must be less than 100 characters';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }
    
    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }

  // Review validation
  static String? validateReview(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review is required';
    }
    
    if (value.trim().length < 10) {
      return 'Review must be at least 10 characters';
    }
    
    if (value.length > 1000) {
      return 'Review must be less than 1000 characters';
    }
    
    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Generic length validation
  static String? validateLength(String? value, String fieldName, {int? minLength, int? maxLength}) {
    if (value == null) return null;
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }

  // Combine multiple validators
  static String? combineValidators(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
