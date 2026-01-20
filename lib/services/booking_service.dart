import '../core/app_config.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import 'firestore_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Create a new booking
  Future<String?> createBooking({
    required String clientId,
    required String productId,
    required String clientName,
    required String productTitle,
    DateTime? scheduledDate,
    String? notes,
    String? address,
    String? phoneNumber,
    double? totalAmount,
  }) async {
    try {
      AppConfig.log('Creating booking for client: $clientId, product: $productId');
      
      final booking = BookingModel(
        id: '', // Will be set by Firestore
        clientId: clientId,
        productId: productId,
        status: 'pending',
        scheduledDate: scheduledDate,
        notes: notes,
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        clientName: clientName,
        productTitle: productTitle,
        address: address,
        phoneNumber: phoneNumber,
        statusHistory: ['pending'],
      );
      
      final bookingId = await _firestoreService.createBooking(booking);
      AppConfig.log('Booking created successfully with ID: $bookingId');
      
      return bookingId;
    } catch (e) {
      AppConfig.logError('Failed to create booking', e);
      return null;
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      return await _firestoreService.getBooking(bookingId);
    } catch (e) {
      AppConfig.logError('Failed to get booking', e);
      return null;
    }
  }

  // Get bookings for user based on role
  Stream<List<BookingModel>> getBookingsForUser(String userId, String role) {
    try {
      AppConfig.log('Getting bookings for user: $userId, role: $role');
      return _firestoreService.getBookingsForUser(userId, role);
    } catch (e) {
      AppConfig.logError('Failed to get bookings for user', e);
      return Stream.value([]);
    }
  }

  // Get bookings by status
  Stream<List<BookingModel>> getBookingsByStatus(String status) {
    try {
      AppConfig.log('Getting bookings with status: $status');
      return _firestoreService.getBookingsByStatus(status);
    } catch (e) {
      AppConfig.logError('Failed to get bookings by status', e);
      return Stream.value([]);
    }
  }

  // Assign booking to employee
  Future<bool> assignBookingToEmployee(String bookingId, String employeeId, String employeeName) async {
    try {
      AppConfig.log('Assigning booking $bookingId to employee $employeeId');
      
      await _firestoreService.updateBooking(bookingId, {
        'employeeId': employeeId,
        'employeeName': employeeName,
        'status': 'assigned',
        'statusHistory': ['pending', 'assigned'],
      });
      
      AppConfig.log('Booking assigned successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to assign booking to employee', e);
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String newStatus, {String? notes}) async {
    try {
      AppConfig.log('Updating booking $bookingId status to $newStatus');
      
      // Get current booking to update status history
      final currentBooking = await _firestoreService.getBooking(bookingId);
      if (currentBooking == null) {
        AppConfig.logError('Booking not found: $bookingId');
        return false;
      }
      
      // Validate status transition
      if (!_isValidStatusTransition(currentBooking.status, newStatus)) {
        AppConfig.logError('Invalid status transition from ${currentBooking.status} to $newStatus');
        return false;
      }
      
      // Update status history
      final updatedStatusHistory = List<String>.from(currentBooking.statusHistory);
      if (!updatedStatusHistory.contains(newStatus)) {
        updatedStatusHistory.add(newStatus);
      }
      
      final updateData = <String, dynamic>{
        'status': newStatus,
        'statusHistory': updatedStatusHistory,
      };
      
      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }
      
      await _firestoreService.updateBooking(bookingId, updateData);
      
      AppConfig.log('Booking status updated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update booking status', e);
      return false;
    }
  }

  // Start booking (employee action)
  Future<bool> startBooking(String bookingId, {String? notes}) async {
    return await updateBookingStatus(bookingId, 'active', notes: notes);
  }

  // Complete booking (employee action)
  Future<bool> completeBooking(String bookingId, {String? notes}) async {
    return await updateBookingStatus(bookingId, 'completed', notes: notes);
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    return await updateBookingStatus(bookingId, 'cancelled', notes: reason);
  }

  // Reschedule booking
  Future<bool> rescheduleBooking(String bookingId, DateTime newScheduledDate, {String? notes}) async {
    try {
      AppConfig.log('Rescheduling booking $bookingId to $newScheduledDate');
      
      await _firestoreService.updateBooking(bookingId, {
        'scheduledDate': newScheduledDate,
        'notes': notes,
      });
      
      AppConfig.log('Booking rescheduled successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to reschedule booking', e);
      return false;
    }
  }

  // Get available employees for assignment
  Future<List<UserModel>> getAvailableEmployees() async {
    try {
      AppConfig.log('Getting available employees');
      
      // This is a simplified version. In a real app, you might want to check
      // employee availability, workload, location, etc.
      final employees = await _firestoreService.getUsersByRole('employee').first;
      
      AppConfig.log('Found ${employees.length} available employees');
      return employees.where((employee) => employee.isActive).toList();
    } catch (e) {
      AppConfig.logError('Failed to get available employees', e);
      return [];
    }
  }

  // Get booking statistics for admin dashboard
  Future<Map<String, dynamic>> getBookingStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      AppConfig.log('Getting booking statistics');
      
      final stats = await _firestoreService.getBookingStatistics();
      
      // Calculate additional metrics
      final totalBookings = stats['total'] ?? 0;
      final completedBookings = stats['completed'] ?? 0;
      final cancelledBookings = stats['cancelled'] ?? 0;
      
      final completionRate = totalBookings > 0 ? (completedBookings / totalBookings * 100) : 0.0;
      final cancellationRate = totalBookings > 0 ? (cancelledBookings / totalBookings * 100) : 0.0;
      
      final enhancedStats = Map<String, dynamic>.from(stats);
      enhancedStats['completionRate'] = completionRate;
      enhancedStats['cancellationRate'] = cancellationRate;
      
      AppConfig.log('Booking statistics calculated successfully');
      return enhancedStats;
    } catch (e) {
      AppConfig.logError('Failed to get booking statistics', e);
      return {};
    }
  }

  // Get bookings for employee dashboard
  Stream<List<BookingModel>> getEmployeeBookings(String employeeId) {
    try {
      AppConfig.log('Getting bookings for employee: $employeeId');
      return _firestoreService.getBookingsForUser(employeeId, 'employee');
    } catch (e) {
      AppConfig.logError('Failed to get employee bookings', e);
      return Stream.value([]);
    }
  }

  // Get pending bookings for admin
  Stream<List<BookingModel>> getPendingBookings() {
    try {
      AppConfig.log('Getting pending bookings for admin');
      return _firestoreService.getBookingsByStatus('pending');
    } catch (e) {
      AppConfig.logError('Failed to get pending bookings', e);
      return Stream.value([]);
    }
  }

  // Search bookings
  Future<List<BookingModel>> searchBookings(String query, String userRole, String userId) async {
    try {
      AppConfig.log('Searching bookings with query: $query');
      
      // Get all bookings for the user
      final bookings = await getBookingsForUser(userId, userRole).first;
      
      // Filter bookings based on search query
      final filteredBookings = bookings.where((booking) {
        final lowerQuery = query.toLowerCase();
        return (booking.clientName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (booking.employeeName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (booking.productTitle?.toLowerCase().contains(lowerQuery) ?? false) ||
               booking.status.toLowerCase().contains(lowerQuery) ||
               (booking.notes?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
      
      AppConfig.log('Found ${filteredBookings.length} bookings matching query');
      return filteredBookings;
    } catch (e) {
      AppConfig.logError('Failed to search bookings', e);
      return [];
    }
  }

  // Get booking details with related data
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      AppConfig.log('Getting booking details for: $bookingId');
      
      final booking = await _firestoreService.getBooking(bookingId);
      if (booking == null) {
        AppConfig.logError('Booking not found: $bookingId');
        return null;
      }
      
      // Get related data
      final client = await _firestoreService.getUser(booking.clientId);
      final employee = booking.employeeId != null 
          ? await _firestoreService.getUser(booking.employeeId!)
          : null;
      final product = await _firestoreService.getProduct(booking.productId);
      
      return {
        'booking': booking,
        'client': client,
        'employee': employee,
        'product': product,
      };
    } catch (e) {
      AppConfig.logError('Failed to get booking details', e);
      return null;
    }
  }

  // Validate status transition
  bool _isValidStatusTransition(String currentStatus, String newStatus) {
    const validTransitions = {
      'pending': ['assigned', 'cancelled'],
      'assigned': ['active', 'cancelled'],
      'active': ['completed', 'cancelled'],
      'completed': [], // No transitions from completed
      'cancelled': [], // No transitions from cancelled
    };
    
    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  // Get next possible statuses for a booking
  List<String> getNextPossibleStatuses(String currentStatus) {
    const validTransitions = {
      'pending': ['assigned', 'cancelled'],
      'assigned': ['active', 'cancelled'],
      'active': ['completed', 'cancelled'],
      'completed': [],
      'cancelled': [],
    };
    
    return (validTransitions[currentStatus] ?? []).cast<String>();
  }

  // Check if user can perform action on booking
  bool canUserPerformAction(BookingModel booking, String userId, String userRole, String action) {
    switch (action) {
      case 'assign':
        return userRole == 'admin';
      case 'start':
        return userRole == 'employee' && booking.employeeId == userId && booking.status == 'assigned';
      case 'complete':
        return userRole == 'employee' && booking.employeeId == userId && booking.status == 'active';
      case 'cancel':
        return (userRole == 'admin') || 
               (userRole == 'client' && booking.clientId == userId && booking.canBeCancelled) ||
               (userRole == 'employee' && booking.employeeId == userId && booking.canBeCancelled);
      case 'reschedule':
        return (userRole == 'admin') || 
               (userRole == 'client' && booking.clientId == userId && booking.canBeCancelled);
      case 'view':
        return (userRole == 'admin') ||
               (booking.clientId == userId) ||
               (booking.employeeId == userId);
      default:
        return false;
    }
  }

  // Get booking summary for dashboard
  Future<Map<String, dynamic>> getBookingSummary(String userId, String userRole) async {
    try {
      AppConfig.log('Getting booking summary for user: $userId, role: $userRole');
      
      final bookings = await getBookingsForUser(userId, userRole).first;
      
      final summary = <String, dynamic>{
        'total': bookings.length,
        'pending': bookings.where((b) => b.status == 'pending').length,
        'assigned': bookings.where((b) => b.status == 'assigned').length,
        'active': bookings.where((b) => b.status == 'active').length,
        'completed': bookings.where((b) => b.status == 'completed').length,
        'cancelled': bookings.where((b) => b.status == 'cancelled').length,
      };
      
      // Add role-specific metrics
      if (userRole == 'employee') {
        summary['todayJobs'] = bookings.where((b) => 
          b.scheduledDate != null && 
          _isSameDay(b.scheduledDate!, DateTime.now()) &&
          ['assigned', 'active'].contains(b.status)
        ).length;
      }
      
      AppConfig.log('Booking summary calculated successfully');
      return summary;
    } catch (e) {
      AppConfig.logError('Failed to get booking summary', e);
      return {};
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}