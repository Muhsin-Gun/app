import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isEmailVerified;
  final bool isApproved;
  final bool profileCompleted;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isApproved = false,
    this.profileCompleted = false,
    this.metadata,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isApproved': isApproved,
      'profileCompleted': profileCompleted,
      'metadata': metadata,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      isEmailVerified: map['isEmailVerified'] ?? false,
      isApproved: map['isApproved'] ?? false,
      profileCompleted: map['profileCompleted'] ?? false,
      metadata: map['metadata'],
    );
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isApproved,
    bool? profileCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isApproved: isApproved ?? this.isApproved,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is client
  bool get isClient => role == 'client';

  // Check if user is employee
  bool get isEmployee => role == 'employee';

  // Check if user is new (just created)
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inMinutes < 5; // Consider new if created within 5 minutes
  }

  // Get display name (fallback to email if name is empty)
  String get displayName => name.isNotEmpty ? name : email;

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return email.substring(0, 1).toUpperCase();
    
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  // Validate user data
  bool get isValid {
    return uid.isNotEmpty &&
           name.isNotEmpty &&
           email.isNotEmpty &&
           email.contains('@') &&
           ['admin', 'client', 'employee'].contains(role);
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role, isActive: $isActive, isApproved: $isApproved, profileCompleted: $profileCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
           other.uid == uid &&
           other.name == name &&
           other.email == email &&
           other.role == role &&
           other.photoUrl == photoUrl &&
           other.phone == phone &&
           other.isActive == isActive &&
           other.isEmailVerified == isEmailVerified &&
           other.isApproved == isApproved &&
           other.profileCompleted == profileCompleted;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
           name.hashCode ^
           email.hashCode ^
           role.hashCode ^
           photoUrl.hashCode ^
           phone.hashCode ^
           isActive.hashCode ^
           isEmailVerified.hashCode ^
           isApproved.hashCode ^
           profileCompleted.hashCode;
  }
}
