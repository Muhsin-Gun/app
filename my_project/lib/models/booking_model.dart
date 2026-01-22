
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String clientId;
  final String? clientName; // Added back
  final String productId;
  final String? productTitle;

  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;

  final String? employeeId;
  final String? employeeName;

  final double? totalAmount;
  final String? notes; // Added back

  final String? phoneNumber;
  final String? address;

  final List<String> statusHistory;
  
  // Internal helper for UI logic locally if needed, though status covers most
  final bool? isRated;

  BookingModel({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.productId,
    this.productTitle,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.employeeId,
    this.employeeName,
    this.totalAmount,
    this.notes,
    this.phoneNumber,
    this.address,
    List<String>? statusHistory,
    this.isRated,
  }) : statusHistory = statusHistory ?? [];

  /// ---------------- FIRESTORE ----------------

  factory BookingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'],
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      scheduledDate: data['scheduledDate'] != null
          ? (data['scheduledDate'] as Timestamp).toDate()
          : null,
      employeeId: data['employeeId'],
      employeeName: data['employeeName'],
      totalAmount: (data['totalAmount'] as num?)?.toDouble(),
      notes: data['notes'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      statusHistory: List<String>.from(data['statusHistory'] ?? []),
      isRated: data['isRated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'productId': productId,
      'productTitle': productTitle,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'totalAmount': totalAmount,
      'notes': notes,
      'phoneNumber': phoneNumber,
      'address': address,
      'statusHistory': statusHistory,
      'isRated': isRated,
    };
  }

  /// ---------------- UI HELPERS ----------------

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canBeCancelled {
    return status == 'pending' || status == 'assigned';
  }

  String get timeSinceCreation {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
  BookingModel copyWith({
    String? status,
    String? employeeId,
    String? employeeName,
  }) {
    return BookingModel(
      id: id,
      clientId: clientId,
      clientName: clientName,
      productId: productId,
      productTitle: productTitle,
      status: status ?? this.status,
      createdAt: createdAt,
      scheduledDate: scheduledDate,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      totalAmount: totalAmount,
      notes: notes,
      phoneNumber: phoneNumber,
      address: address,
      statusHistory: statusHistory,
      isRated: isRated,
    );
  }
}
