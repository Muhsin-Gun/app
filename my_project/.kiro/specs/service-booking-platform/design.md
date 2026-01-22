# Design Document

## Overview

The Service Booking Platform is a Flutter application that implements a comprehensive multi-role marketplace connecting service providers with clients. The system leverages Firebase for authentication and data storage, Cloudinary for image management, and provides real-time messaging capabilities. The architecture supports three distinct user roles with dedicated dashboards and cross-platform deployment (Android, iOS, Web).

## Architecture

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   Cloudinary    │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │    Auth     │ │◄──►│ │    Auth     │ │    │ │   Image     │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ │  Storage    │ │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ └─────────────┘ │
│ │  Firestore  │ │◄──►│ │  Firestore  │ │    └─────────────────┘
│ │   Service   │ │    │ │  Database   │ │
│ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    └─────────────────┘
│ │ Role-Based  │ │
│ │ Navigation  │ │
│ └─────────────┘ │
└─────────────────┘
```

### Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants.dart
│   ├── theme.dart
│   └── app_config.dart
├── models/
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── booking_model.dart
│   └── message_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── cloudinary_service.dart
│   ├── google_signin_service.dart
│   ├── booking_service.dart
│   └── message_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── booking_provider.dart
│   ├── message_provider.dart
│   └── employee_provider.dart
├── routing/
│   └── app_router.dart
├── utils/
│   ├── validators.dart
│   └── image_helpers.dart
├── widgets/
│   ├── custom_bottom_bar.dart
│   ├── custom_icon_widget.dart
│   └── custom_image_widget.dart
└── features/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── onboarding_screen.dart
    │   └── role_selector_screen.dart
    ├── admin/
    │   ├── admin_dashboard_screen.dart
    │   ├── product_create_screen.dart
    │   ├── product_list_screen.dart
    │   ├── booking_management_screen.dart
    │   ├── employee_management_screen.dart
    │   └── messages_screen.dart
    ├── client/
    │   ├── client_dashboard_screen.dart
    │   ├── browse_screen.dart
    │   ├── booking_screen.dart
    │   ├── messages_screen.dart
    │   ├── profile_screen.dart
    │   └── product_detail_screen.dart
    └── employee/
        ├── employee_dashboard_screen.dart
        ├── assigned_jobs_screen.dart
        ├── job_detail_screen.dart
        ├── completed_jobs_screen.dart
        └── messages_screen.dart
```

## Components and Interfaces

### Authentication Flow

The authentication system uses the existing Google Sign-In implementation from your README.md code:

```dart
// Based on your existing LoginScreen implementation
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    return await _auth.signInWithCredential(credential);
  }
}
```

### Role-Based Navigation

Building on your existing client dashboard structure:

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => AuthGate());
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => AdminDashboard());
      case '/client-dashboard':
        return MaterialPageRoute(builder: (_) => ClientDashboard());
      case '/employee-dashboard':
        return MaterialPageRoute(builder: (_) => EmployeeDashboard());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
```

### Service Layer Architecture

#### Firebase Service Integration
```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // User Management
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }
  
  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }
  
  // Product Management
  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection('products').snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }
  
  // Booking Management
  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }
  
  Stream<List<BookingModel>> getBookingsForUser(String userId, String role) {
    Query query = _db.collection('bookings');
    
    switch (role) {
      case 'client':
        query = query.where('clientId', isEqualTo: userId);
        break;
      case 'employee':
        query = query.where('employeeId', isEqualTo: userId);
        break;
      case 'admin':
        // Admin sees all bookings
        break;
    }
    
    return query.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList());
  }
}
```

#### Cloudinary Integration
Using your existing image upload pattern:

```dart
class CloudinaryService {
  static const String cloudName = 'your_cloud_name';
  static const String uploadPreset = 'your_upload_preset';
  
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
    );
    
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['secure_url'];
      }
    } catch (e) {
      print('Image upload error: $e');
    }
    return null;
  }
}
```

## Data Models

### User Model
```dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin', 'client', 'employee'
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'role': role,
    'photoUrl': photoUrl,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    role: map['role'],
    photoUrl: map['photoUrl'],
    phone: map['phone'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
```

### Product Model
```dart
class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdBy,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    price: map['price'].toDouble(),
    imageUrl: map['imageUrl'],
    category: map['category'],
    createdBy: map['createdBy'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
```

### Booking Model
```dart
class BookingModel {
  final String id;
  final String clientId;
  final String? employeeId;
  final String productId;
  final String status; // 'pending', 'assigned', 'active', 'completed'
  final DateTime? scheduledDate;
  final String? notes;
  final DateTime createdAt;
  
  BookingModel({
    required this.id,
    required this.clientId,
    this.employeeId,
    required this.productId,
    required this.status,
    this.scheduledDate,
    this.notes,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'employeeId': employeeId,
    'productId': productId,
    'status': status,
    'scheduledDate': scheduledDate?.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'],
    clientId: map['clientId'],
    employeeId: map['employeeId'],
    productId: map['productId'],
    status: map['status'],
    scheduledDate: map['scheduledDate'] != null 
        ? DateTime.parse(map['scheduledDate']) 
        : null,
    notes: map['notes'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
```

### Message Model
```dart
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? bookingId;
  final String content;
  final DateTime timestamp;
  
  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.bookingId,
    required this.content,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'bookingId': bookingId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    id: map['id'],
    senderId: map['senderId'],
    receiverId: map['receiverId'],
    bookingId: map['bookingId'],
    content: map['content'],
    timestamp: DateTime.parse(map['timestamp']),
  );
}
```

## Dashboard Implementations

### Admin Dashboard Features
- Product CRUD operations with Cloudinary image upload
- Booking management and employee assignment
- Employee management and role assignment
- Analytics and reporting dashboard
- Real-time messaging interface

### Client Dashboard Features
Building on your existing `ClientDashboardInitialPage`:
- Service browsing with dynamic Firestore data
- Service booking creation and management
- Real-time booking status updates
- Messaging with assigned employees
- Profile management

### Employee Dashboard Features
- Assigned job listings and management
- Job status updates (pending → active → completed)
- Client communication interface
- Completed job history
- Performance metrics

## Error Handling

### Network Error Handling
```dart
class ErrorHandler {
  static void handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          showErrorToast('Access denied. Please check your permissions.');
          break;
        case 'unavailable':
          showErrorToast('Service temporarily unavailable. Please try again.');
          break;
        default:
          showErrorToast('An error occurred: ${error.message}');
      }
    }
  }
  
  static void handleCloudinaryError(dynamic error) {
    showErrorToast('Image upload failed. Please try again.');
  }
  
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
```

### Offline Handling
```dart
class ConnectivityService {
  static Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  static void handleOfflineMode() {
    showErrorToast('You are offline. Some features may not be available.');
  }
}
```

## Testing Strategy

### Unit Tests
- Service layer testing (AuthService, FirestoreService, CloudinaryService)
- Model validation and serialization testing
- Provider state management testing
- Utility function testing

### Integration Tests
- Authentication flow testing
- Booking creation and assignment flow
- Real-time messaging functionality
- Cross-role interaction testing

### Widget Tests
- Dashboard rendering tests
- Form validation tests
- Navigation flow tests
- Responsive design tests

### End-to-End Tests
- Complete user journey testing
- Cross-platform functionality verification
- Performance and load testing
- Security and permission testing

## Security Considerations

### Firebase Security Rules
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are publicly readable, admin writable
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Bookings access based on role
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.employeeId == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
    }
    
    // Messages access for participants
    match /messages/{messageId} {
      allow read, write: if request.auth != null && (
        resource.data.senderId == request.auth.uid ||
        resource.data.receiverId == request.auth.uid
      );
    }
  }
}
```

### Data Validation
- Input sanitization for all user inputs
- Image file type and size validation
- Role-based access control enforcement
- Secure API key management for Cloudinary

## Performance Optimization

### Firestore Optimization
- Implement pagination for large data sets
- Use compound indexes for complex queries
- Implement data caching with SharedPreferences
- Optimize real-time listeners to prevent excessive reads

### Image Optimization
- Implement image compression before Cloudinary upload
- Use Cloudinary transformations for responsive images
- Implement lazy loading for image lists
- Cache images locally using cached_network_image

### State Management Optimization
- Use Provider for efficient state updates
- Implement selective rebuilds with Consumer widgets
- Optimize stream subscriptions and disposal
- Implement proper loading states and error handling