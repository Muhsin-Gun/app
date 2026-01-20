import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../services/message_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final MessageService _messageService = MessageService();

  // Private variables
  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  List<UserModel> _availableEmployees = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = '';
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  bool _sortAscending = false;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<BookingModel> get bookings => _filteredBookings;
  List<BookingModel> get allBookings => _bookings;
  List<UserModel> get availableEmployees => _availableEmployees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  Map<String, dynamic> get statistics => _statistics;
  int get bookingCount => _filteredBookings.length;
  int get totalBookingCount => _bookings.length;

  // Initialize bookings for user
  void initializeBookings(String userId, String userRole) {
    try {
      AppConfig.log('Initializing BookingProvider for user: $userId, role: $userRole');
      
      _bookingService.getBookingsForUser(userId, userRole).listen(
        (bookings) {
          _bookings = bookings;
          _applyFilters();
          _updateStatistics();
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          AppConfig.logError('Error in bookings stream', error);
          _setError('Failed to load bookings');
        },
      );
      
      // Load available employees if user is admin
      if (userRole == 'admin') {
        _loadAvailableEmployees();
      }
      
      AppConfig.log('BookingProvider initialized successfully');
    } catch (e) {
      AppConfig.logError('Failed to initialize BookingProvider', e);
      _setError('Failed to initialize bookings');
    }
  }

  // Create new booking
  Future<bool> createBooking({
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
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Creating booking for product: $productTitle');
      
      final bookingId = await _bookingService.createBooking(
        clientId: clientId,
        productId: productId,
        clientName: clientName,
        productTitle: productTitle,
        scheduledDate: scheduledDate,
        notes: notes,
        address: address,
        phoneNumber: phoneNumber,
        totalAmount: totalAmount,
      );
      
      if (bookingId != null) {
        AppConfig.log('Booking created successfully with ID: $bookingId');
        return true;
      } else {
        _setError('Failed to create booking');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to create booking', e);
      _setError('Failed to create booking');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign booking to employee
  Future<bool> assignBookingToEmployee(String bookingId, String employeeId, String employeeName) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Assigning booking $bookingId to employee $employeeId');
      
      final success = await _bookingService.assignBookingToEmployee(bookingId, employeeId, employeeName);
      
      if (success) {
        // Send notification message to client
        final booking = await _bookingService.getBooking(bookingId);
        if (booking != null) {
          await _messageService.sendBookingStatusUpdateMessage(
            bookingId: bookingId,
            clientId: booking.clientId,
            newStatus: 'assigned',
            employeeId: employeeId,
            employeeName: employeeName,
          );
        }
        
        AppConfig.log('Booking assigned successfully');
        return true;
      } else {
        _setError('Failed to assign booking');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to assign booking', e);
      _setError('Failed to assign booking');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String newStatus, {String? notes}) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating booking $bookingId status to $newStatus');
      
      final success = await _bookingService.updateBookingStatus(bookingId, newStatus, notes: notes);
      
      if (success) {
        // Send notification message to client
        final booking = await _bookingService.getBooking(bookingId);
        if (booking != null) {
          await _messageService.sendBookingStatusUpdateMessage(
            bookingId: bookingId,
            clientId: booking.clientId,
            newStatus: newStatus,
            employeeId: booking.employeeId,
            employeeName: booking.employeeName,
          );
        }
        
        AppConfig.log('Booking status updated successfully');
        return true;
      } else {
        _setError('Failed to update booking status');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to update booking status', e);
      _setError('Failed to update booking status');
      return false;
    } finally {
      _setLoading(false);
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
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Rescheduling booking $bookingId');
      
      final success = await _bookingService.rescheduleBooking(bookingId, newScheduledDate, notes: notes);
      
      if (success) {
        AppConfig.log('Booking rescheduled successfully');
        return true;
      } else {
        _setError('Failed to reschedule booking');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Failed to reschedule booking', e);
      _setError('Failed to reschedule booking');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get booking details
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      return await _bookingService.getBookingDetails(bookingId);
    } catch (e) {
      AppConfig.logError('Failed to get booking details', e);
      return null;
    }
  }

  // Search bookings
  void searchBookings(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = '';
    _applyFilters();
    notifyListeners();
  }

  // Sort bookings
  void sortBookings(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applySorting();
    notifyListeners();
  }

  // Get bookings by status
  List<BookingModel> getBookingsByStatus(String status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Get pending bookings
  List<BookingModel> getPendingBookings() {
    return getBookingsByStatus('pending');
  }

  // Get active bookings
  List<BookingModel> getActiveBookings() {
    return getBookingsByStatus('active');
  }

  // Get completed bookings
  List<BookingModel> getCompletedBookings() {
    return getBookingsByStatus('completed');
  }

  // Get today's bookings
  List<BookingModel> getTodaysBookings() {
    final today = DateTime.now();
    return _bookings.where((booking) => 
      booking.scheduledDate != null &&
      _isSameDay(booking.scheduledDate!, today)
    ).toList();
  }

  // Get upcoming bookings
  List<BookingModel> getUpcomingBookings({int days = 7}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return _bookings.where((booking) => 
      booking.scheduledDate != null &&
      booking.scheduledDate!.isAfter(now) &&
      booking.scheduledDate!.isBefore(futureDate) &&
      ['assigned', 'active'].contains(booking.status)
    ).toList();
  }

  // Get overdue bookings
  List<BookingModel> getOverdueBookings() {
    final now = DateTime.now();
    
    return _bookings.where((booking) => 
      booking.scheduledDate != null &&
      booking.scheduledDate!.isBefore(now) &&
      ['pending', 'assigned'].contains(booking.status)
    ).toList();
  }

  // Check if user can perform action on booking
  bool canUserPerformAction(BookingModel booking, String userId, String userRole, String action) {
    return _bookingService.canUserPerformAction(booking, userId, userRole, action);
  }

  // Get next possible statuses for booking
  List<String> getNextPossibleStatuses(String currentStatus) {
    return _bookingService.getNextPossibleStatuses(currentStatus);
  }

  // Get booking summary
  Future<Map<String, dynamic>> getBookingSummary(String userId, String userRole) async {
    try {
      return await _bookingService.getBookingSummary(userId, userRole);
    } catch (e) {
      AppConfig.logError('Failed to get booking summary', e);
      return {};
    }
  }

  // Load available employees
  Future<void> _loadAvailableEmployees() async {
    try {
      _availableEmployees = await _bookingService.getAvailableEmployees();
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to load available employees', e);
    }
  }

  // Apply filters and search
  void _applyFilters() {
    _filteredBookings = List<BookingModel>.from(_bookings);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredBookings = _filteredBookings.where((booking) =>
        (booking.clientName?.toLowerCase().contains(_searchQuery) ?? false) ||
        (booking.employeeName?.toLowerCase().contains(_searchQuery) ?? false) ||
        (booking.productTitle?.toLowerCase().contains(_searchQuery) ?? false) ||
        booking.status.toLowerCase().contains(_searchQuery) ||
        (booking.notes?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }
    
    // Apply status filter
    if (_filterStatus.isNotEmpty) {
      _filteredBookings = _filteredBookings.where((booking) =>
        booking.status == _filterStatus
      ).toList();
    }
    
    // Apply sorting
    _applySorting();
  }

  // Apply sorting
  void _applySorting() {
    switch (_sortBy) {
      case 'clientName':
        _filteredBookings.sort((a, b) => _sortAscending 
          ? (a.clientName ?? '').compareTo(b.clientName ?? '')
          : (b.clientName ?? '').compareTo(a.clientName ?? ''));
        break;
      case 'status':
        _filteredBookings.sort((a, b) => _sortAscending 
          ? a.status.compareTo(b.status)
          : b.status.compareTo(a.status));
        break;
      case 'scheduledDate':
        _filteredBookings.sort((a, b) {
          if (a.scheduledDate == null && b.scheduledDate == null) return 0;
          if (a.scheduledDate == null) return _sortAscending ? 1 : -1;
          if (b.scheduledDate == null) return _sortAscending ? -1 : 1;
          return _sortAscending 
            ? a.scheduledDate!.compareTo(b.scheduledDate!)
            : b.scheduledDate!.compareTo(a.scheduledDate!);
        });
        break;
      case 'totalAmount':
        _filteredBookings.sort((a, b) {
          final aAmount = a.totalAmount ?? 0;
          final bAmount = b.totalAmount ?? 0;
          return _sortAscending 
            ? aAmount.compareTo(bAmount)
            : bAmount.compareTo(aAmount);
        });
        break;
      case 'createdAt':
      default:
        _filteredBookings.sort((a, b) => _sortAscending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // Update statistics
  void _updateStatistics() {
    _statistics = {
      'total': _bookings.length,
      'pending': _bookings.where((b) => b.status == 'pending').length,
      'assigned': _bookings.where((b) => b.status == 'assigned').length,
      'active': _bookings.where((b) => b.status == 'active').length,
      'completed': _bookings.where((b) => b.status == 'completed').length,
      'cancelled': _bookings.where((b) => b.status == 'cancelled').length,
      'today': getTodaysBookings().length,
      'upcoming': getUpcomingBookings().length,
      'overdue': getOverdueBookings().length,
    };
    
    // Calculate completion rate
    final totalCompleted = _statistics['completed'] as int;
    final totalNonPending = _bookings.where((b) => b.status != 'pending').length;
    _statistics['completionRate'] = totalNonPending > 0 ? (totalCompleted / totalNonPending * 100) : 0.0;
  }

  // Refresh bookings
  Future<void> refreshBookings() async {
    try {
      AppConfig.log('Refreshing bookings');
      // The stream will automatically update the bookings
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to refresh bookings', e);
      _setError('Failed to refresh bookings');
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    AppConfig.log('Disposing BookingProvider');
    super.dispose();
  }
}