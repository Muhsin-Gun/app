import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../core/constants.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _bookingsSubscription;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? _role;

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }

  // Fetch bookings based on user role with real-time updates
  Future<void> initializeBookings(String userId, String role) async {
    _userId = userId;
    _role = role;
    _isLoading = true;
    notifyListeners();

    await _bookingsSubscription?.cancel();

    try {
      Query query = _firestore.collection(AppConstants.bookingsCollection);

      if (role == 'client') {
        query = query.where('clientId', isEqualTo: userId);
      } else if (role == 'employee') {
        query = query.where('providerId', isEqualTo: userId);
      }
      // Admin sees all

      _bookingsSubscription = query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _bookings = snapshot.docs
                  .map((doc) => BookingModel.fromDocument(doc))
                  .toList();
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();
            },
            onError: (e) {
              _errorMessage = 'Stream error: $e';
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = 'Failed to load bookings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new booking
  Future<bool> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .add(booking.toMap());
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create booking: $e';
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateStatus(String bookingId, String newStatus) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .update({'status': newStatus});
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
      return false;
    }
  }

  // Assign an employee to a booking
  Future<bool> assignEmployee(
    String bookingId,
    String employeeId,
    String employeeName,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .update({
            'employeeId': employeeId,
            'employeeName': employeeName,
            'status': 'assigned',
            'assignedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign employee: $e';
      notifyListeners();
      return false;
    }
  }

  // Getters for Analytics
  int get totalBookingCount => _bookings.length;

  List<BookingModel> getPendingBookings() {
    return _bookings.where((b) => b.status == 'pending').toList();
  }

  Future<void> refreshBookings() async {
    if (_userId != null && _role != null) {
      await initializeBookings(_userId!, _role!);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await updateStatus(bookingId, newStatus);
  }
}
