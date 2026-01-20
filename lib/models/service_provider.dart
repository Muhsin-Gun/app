class ServiceProvider {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String category;
  final String bio;
  final String specialization;
  final double hourlyRate;
  final double rating;
  final int reviewsCount;
  final int completedJobs;
  final bool isVerified;
  final List<String> skills;
  final DateTime createdAt;

  ServiceProvider({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.category,
    required this.bio,
    required this.specialization,
    required this.hourlyRate,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobs,
    required this.isVerified,
    required this.skills,
    required this.createdAt,
  });

  factory ServiceProvider.fromMap(Map<String, dynamic> map) {
    return ServiceProvider(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      category: map['category'] ?? '',
      bio: map['bio'] ?? '',
      specialization: map['specialization'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      completedJobs: map['completedJobs'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      skills: List<String>.from(map['skills'] ?? []),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'category': category,
      'bio': bio,
      'specialization': specialization,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'completedJobs': completedJobs,
      'isVerified': isVerified,
      'skills': skills,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
