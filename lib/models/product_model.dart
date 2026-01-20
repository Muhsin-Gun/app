import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final double? rating;
  final int reviewCount;
  final String? duration;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.tags = const [],
    this.metadata,
    this.rating,
    this.reviewCount = 0,
    this.duration,
    this.isAvailable = true,
  });

  // Convert ProductModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'tags': tags,
      'metadata': metadata,
      'rating': rating,
      'reviewCount': reviewCount,
      'duration': duration,
      'isAvailable': isAvailable,
    };
  }

  // Create ProductModel from Firestore document
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      duration: map['duration'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  // Create ProductModel from Firestore DocumentSnapshot
  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Ensure ID is set from document ID
    return ProductModel.fromMap(data);
  }

  // Copy with method for updating product data
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    double? rating,
    int? reviewCount,
    String? duration,
    bool? isAvailable,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      duration: duration ?? this.duration,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  // Get formatted price
  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Get formatted rating
  String get formattedRating {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} (${reviewCount} reviews)';
  }

  // Get short description (first 100 characters)
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  // Check if product has image
  bool get hasImage => imageUrl.isNotEmpty;

  // Check if product is bookable
  bool get isBookable => isActive && isAvailable;

  // Get category display name
  String get categoryDisplayName {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  // Validate product data
  bool get isValid {
    return id.isNotEmpty &&
           title.isNotEmpty &&
           description.isNotEmpty &&
           price > 0 &&
           category.isNotEmpty &&
           createdBy.isNotEmpty;
  }

  // Search helper - check if product matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           category.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, price: $price, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
           other.id == id &&
           other.title == title &&
           other.description == description &&
           other.price == price &&
           other.imageUrl == imageUrl &&
           other.category == category &&
           other.createdBy == createdBy &&
           other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           title.hashCode ^
           description.hashCode ^
           price.hashCode ^
           imageUrl.hashCode ^
           category.hashCode ^
           createdBy.hashCode ^
           isActive.hashCode;
  }
}