import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String clientId;
  final String? employeeId;
  final String productId;
  final String status;
  final DateTime? scheduledDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? totalAmount;
  final String? clientName;
  final String? employeeName;
  final String? productTitle;
  final String? address;
  final String? phoneNumber;
  final Map<String, dynamic>? metadata;
  final List<String> statusHistory;

  BookingModel({
    required this.id,
    required this.clientId,
    this.employeeId,
    required this.productId,
    required this.status,
    this.scheduledDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.totalAmount,
    this.clientName,
    this.employeeName,
    this.productTitle,
    this.address,
    this.phoneNumber,
    this.metadata,
    this.statusHistory = const [],
  });

  // Convert BookingModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'employeeId': employeeId,
      'productId': productId,
      'status': status,
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'totalAmount': totalAmount,
      'clientName': clientName,
      'employeeName': employeeName,
      'productTitle': productTitle,
      'address': address,
      'phoneNumber': phoneNumber,
      'metadata': metadata,
      'statusHistory': statusHistory,
    };
  }

  // Create BookingModel from Firestore document
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      employeeId: map['employeeId'],
      productId: map['productId'] ?? '',
      status: map['status'] ?? 'pending',
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      totalAmount: map['totalAmount']?.toDouble(),
      clientName: map['clientName'],
      employeeName: map['employeeName'],
      productTitle: map['productTitle'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      metadata: map['metadata'],
      statusHistory: List<String>.from(map['statusHistory'] ?? []),
    );
  }

  // Create BookingModel from Firestore DocumentSnapshot
  factory BookingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Ensure ID is set from document ID
    return BookingModel.fromMap(data);
  }

  // Copy with method for updating booking data
  BookingModel copyWith({
    String? id,
    String? clientId,
    String? employeeId,
    String? productId,
    String? status,
    DateTime? scheduledDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalAmount,
    String? clientName,
    String? employeeName,
    String? productTitle,
    String? address,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
    List<String>? statusHistory,
  }) {
    return BookingModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      employeeId: employeeId ?? this.employeeId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalAmount: totalAmount ?? this.totalAmount,
      clientName: clientName ?? this.clientName,
      employeeName: employeeName ?? this.employeeName,
      productTitle: productTitle ?? this.productTitle,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metadata: metadata ?? this.metadata,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  // Status check methods
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Check if booking can be cancelled
  bool get canBeCancelled => isPending || isAssigned;

  // Check if booking can be started
  bool get canBeStarted => isAssigned;

  // Check if booking can be completed
  bool get canBeCompleted => isActive;

  // Check if booking has employee assigned
  bool get hasEmployee => employeeId != null && employeeId!.isNotEmpty;

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending Assignment';
      case 'assigned':
        return 'Assigned';
      case 'active':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#F59E0B'; // Yellow
      case 'assigned':
        return '#3B82F6'; // Blue
      case 'active':
        return '#10B981'; // Green
      case 'completed':
        return '#059669'; // Dark Green
      case 'cancelled':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  // Get formatted total amount
  String get formattedAmount {
    if (totalAmount == null) return 'N/A';
    return '\$${totalAmount!.toStringAsFixed(2)}';
  }

  // Get formatted scheduled date
  String get formattedScheduledDate {
    if (scheduledDate == null) return 'Not scheduled';
    return '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year} at ${scheduledDate!.hour}:${scheduledDate!.minute.toString().padLeft(2, '0')}';
  }

  // Get time since creation
  String get timeSinceCreation {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Validate booking data
  bool get isValid {
    return id.isNotEmpty &&
           clientId.isNotEmpty &&
           productId.isNotEmpty &&
           ['pending', 'assigned', 'active', 'completed', 'cancelled'].contains(status);
  }

  // Get next possible statuses
  List<String> get nextPossibleStatuses {
    switch (status) {
      case 'pending':
        return ['assigned', 'cancelled'];
      case 'assigned':
        return ['active', 'cancelled'];
      case 'active':
        return ['completed', 'cancelled'];
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, clientId: $clientId, employeeId: $employeeId, productId: $productId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel &&
           other.id == id &&
           other.clientId == clientId &&
           other.employeeId == employeeId &&
           other.productId == productId &&
           other.status == status &&
           other.scheduledDate == scheduledDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           clientId.hashCode ^
           employeeId.hashCode ^
           productId.hashCode ^
           status.hashCode ^
           scheduledDate.hashCode;
  }
}