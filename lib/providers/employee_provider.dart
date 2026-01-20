import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../services/booking_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final BookingService _bookingService = BookingService();

  // Private variables
  List<UserModel> _employees = [];
  List<UserModel> _filteredEmployees = [];
  Map<String, List<BookingModel>> _employeeBookings = {};
  Map<String, Map<String, dynamic>> _employeeStatistics = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Getters
  List<UserModel> get employees => _filteredEmployees;
  List<UserModel> get allEmployees => _employees;
  Map<String, List<BookingModel>> get employeeBookings => _employeeBookings;
  Map<String, Map<String, dynamic>> get employeeStatistics => _employeeStatistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  int get employeeCount => _filteredEmployees.length;
  int get totalEmployeeCount => _employees.length;

  EmployeeProvider() {
    _initializeEmployees();
  }

  // Initialize employees stream
  void _initializeEmployees() {
    try {
      AppConfig.log('Initializing EmployeeProvider');
      
      _firestoreService.getUsersByRole('employee').listen(
        (employees) {
          _employees = employees;
          _applyFilters();
          _loadEmployeeData();
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          AppConfig.logError('Error in employees stream', error);
          _setError('Failed to load employees');
        },
      );
      
      AppConfig.log('EmployeeProvider initialized successfully');
    } catch (e) {
      AppConfig.logError('Failed to initialize EmployeeProvider', e);
      _setError('Failed to initialize employees');
    }
  }

  // Create new employee
  Future<bool> createEmployee({
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Creating employee: $email');
      
      // Note: In a real app, you would need to create the Firebase Auth account
      // and then create the Firestore document. This is a simplified version.
      
      final employee = UserModel(
        uid: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: name,
        email: email,
        role: 'employee',
        phone: phone,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.createUser(employee);
      
      AppConfig.log('Employee created successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to create employee', e);
      _setError('Failed to create employee');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update employee
  Future<bool> updateEmployee(
    String employeeId, {
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating employee: $employeeId');
      
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (isActive != null) updateData['isActive'] = isActive;
      
      if (updateData.isNotEmpty) {
        await _firestoreService.updateUser(employeeId, updateData);
        AppConfig.log('Employee updated successfully');
      }
      
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update employee', e);
      _setError('Failed to update employee');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete employee (deactivate)
  Future<bool> deleteEmployee(String employeeId) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Deactivating employee: $employeeId');
      
      // Instead of deleting, we deactivate the employee
      await _firestoreService.updateUser(employeeId, {
        'isActive': false,
      });
      
      AppConfig.log('Employee deactivated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to deactivate employee', e);
      _setError('Failed to deactivate employee');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get employee by ID
  Future<UserModel?> getEmployee(String employeeId) async {
    try {
      return await _firestoreService.getUser(employeeId);
    } catch (e) {
      AppConfig.logError('Failed to get employee', e);
      return null;
    }
  }

  // Get employee bookings
  Future<List<BookingModel>> getEmployeeBookings(String employeeId) async {
    try {
      return await _bookingService.getEmployeeBookings(employeeId).first;
    } catch (e) {
      AppConfig.logError('Failed to get employee bookings', e);
      return [];
    }
  }

  // Get employee statistics
  Future<Map<String, dynamic>> getEmployeeStatistics(String employeeId) async {
    try {
      AppConfig.log('Getting statistics for employee: $employeeId');
      
      final bookings = await getEmployeeBookings(employeeId);
      
      final stats = {
        'totalBookings': bookings.length,
        'completedBookings': bookings.where((b) => b.status == 'completed').length,
        'activeBookings': bookings.where((b) => b.status == 'active').length,
        'cancelledBookings': bookings.where((b) => b.status == 'cancelled').length,
        'pendingBookings': bookings.where((b) => b.status == 'pending').length,
      };
      
      // Calculate completion rate
      final totalCompleted = stats['completedBookings'] as int;
      final totalNonPending = bookings.where((b) => b.status != 'pending').length;
      stats['completionRate'] = totalNonPending > 0 ? ((totalCompleted / totalNonPending * 100).round()) : 0;
      
      // Calculate average rating (if available)
      // This would require a ratings system to be implemented
      stats['averageRating'] = 0;
      
      // Calculate this month's bookings
      final now = DateTime.now();
      final thisMonth = bookings.where((b) => 
        b.createdAt.year == now.year && b.createdAt.month == now.month
      ).length;
      stats['thisMonthBookings'] = thisMonth;
      
      AppConfig.log('Employee statistics calculated successfully');
      return stats;
    } catch (e) {
      AppConfig.logError('Failed to get employee statistics', e);
      return {};
    }
  }

  // Search employees
  void searchEmployees(String query) {
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

  // Sort employees
  void sortEmployees(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applySorting();
    notifyListeners();
  }

  // Get active employees
  List<UserModel> getActiveEmployees() {
    return _employees.where((employee) => employee.isActive).toList();
  }

  // Get available employees (not currently assigned to active bookings)
  Future<List<UserModel>> getAvailableEmployees() async {
    try {
      final activeEmployees = getActiveEmployees();
      final availableEmployees = <UserModel>[];
      
      for (final employee in activeEmployees) {
        final bookings = await getEmployeeBookings(employee.uid);
        final activeBookings = bookings.where((b) => b.status == 'active').length;
        
        // Consider employee available if they have less than 3 active bookings
        if (activeBookings < 3) {
          availableEmployees.add(employee);
        }
      }
      
      return availableEmployees;
    } catch (e) {
      AppConfig.logError('Failed to get available employees', e);
      return [];
    }
  }

  // Get top performing employees
  List<UserModel> getTopPerformingEmployees({int limit = 5}) {
    // Sort by completion rate and total completed bookings
    final employeesWithStats = _employees.where((e) => 
      _employeeStatistics.containsKey(e.uid)
    ).toList();
    
    employeesWithStats.sort((a, b) {
      final aStats = _employeeStatistics[a.uid]!;
      final bStats = _employeeStatistics[b.uid]!;
      
      final aRate = aStats['completionRate'] as double;
      final bRate = bStats['completionRate'] as double;
      
      if (aRate != bRate) {
        return bRate.compareTo(aRate);
      }
      
      final aCompleted = aStats['completedBookings'] as int;
      final bCompleted = bStats['completedBookings'] as int;
      
      return bCompleted.compareTo(aCompleted);
    });
    
    return employeesWithStats.take(limit).toList();
  }

  // Get employee workload
  Future<Map<String, int>> getEmployeeWorkload(String employeeId) async {
    try {
      final bookings = await getEmployeeBookings(employeeId);
      
      return {
        'total': bookings.length,
        'pending': bookings.where((b) => b.status == 'pending').length,
        'assigned': bookings.where((b) => b.status == 'assigned').length,
        'active': bookings.where((b) => b.status == 'active').length,
        'completed': bookings.where((b) => b.status == 'completed').length,
      };
    } catch (e) {
      AppConfig.logError('Failed to get employee workload', e);
      return {};
    }
  }

  // Assign booking to best available employee
  Future<UserModel?> findBestEmployeeForBooking(BookingModel booking) async {
    try {
      final availableEmployees = await getAvailableEmployees();
      
      if (availableEmployees.isEmpty) {
        return null;
      }
      
      // Simple algorithm: choose employee with least active bookings
      UserModel? bestEmployee;
      int minActiveBookings = 999;
      
      for (final employee in availableEmployees) {
        final workload = await getEmployeeWorkload(employee.uid);
        final activeBookings = workload['active'] ?? 0;
        
        if (activeBookings < minActiveBookings) {
          minActiveBookings = activeBookings;
          bestEmployee = employee;
        }
      }
      
      return bestEmployee;
    } catch (e) {
      AppConfig.logError('Failed to find best employee for booking', e);
      return null;
    }
  }

  // Toggle employee active status
  Future<bool> toggleEmployeeStatus(String employeeId, bool isActive) async {
    return await updateEmployee(employeeId, isActive: isActive);
  }

  // Get employee performance summary
  Map<String, dynamic> getEmployeePerformanceSummary() {
    final totalEmployees = _employees.length;
    final activeEmployees = _employees.where((e) => e.isActive).length;
    
    double averageCompletionRate = 0;
    int totalCompletedBookings = 0;
    
    for (final stats in _employeeStatistics.values) {
      averageCompletionRate += stats['completionRate'] as double;
      totalCompletedBookings += stats['completedBookings'] as int;
    }
    
    if (_employeeStatistics.isNotEmpty) {
      averageCompletionRate /= _employeeStatistics.length;
    }
    
    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'averageCompletionRate': averageCompletionRate,
      'totalCompletedBookings': totalCompletedBookings,
    };
  }

  // Load employee data (bookings and statistics)
  Future<void> _loadEmployeeData() async {
    try {
      for (final employee in _employees) {
        // Load bookings
        final bookings = await getEmployeeBookings(employee.uid);
        _employeeBookings[employee.uid] = bookings;
        
        // Calculate statistics
        final stats = await getEmployeeStatistics(employee.uid);
        _employeeStatistics[employee.uid] = stats;
      }
      
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to load employee data', e);
    }
  }

  // Apply filters and search
  void _applyFilters() {
    _filteredEmployees = List<UserModel>.from(_employees);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredEmployees = _filteredEmployees.where((employee) =>
        employee.name.toLowerCase().contains(_searchQuery) ||
        employee.email.toLowerCase().contains(_searchQuery) ||
        (employee.phone?.toLowerCase().contains(_searchQuery) ?? false)
      ).toList();
    }
    
    // Apply status filter
    if (_filterStatus.isNotEmpty) {
      switch (_filterStatus) {
        case 'active':
          _filteredEmployees = _filteredEmployees.where((e) => e.isActive).toList();
          break;
        case 'inactive':
          _filteredEmployees = _filteredEmployees.where((e) => !e.isActive).toList();
          break;
      }
    }
    
    // Apply sorting
    _applySorting();
  }

  // Apply sorting
  void _applySorting() {
    switch (_sortBy) {
      case 'name':
        _filteredEmployees.sort((a, b) => _sortAscending 
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
        break;
      case 'email':
        _filteredEmployees.sort((a, b) => _sortAscending 
          ? a.email.compareTo(b.email)
          : b.email.compareTo(a.email));
        break;
      case 'createdAt':
        _filteredEmployees.sort((a, b) => _sortAscending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
      case 'completionRate':
        _filteredEmployees.sort((a, b) {
          final aRate = _employeeStatistics[a.uid]?['completionRate'] as double? ?? 0;
          final bRate = _employeeStatistics[b.uid]?['completionRate'] as double? ?? 0;
          return _sortAscending 
            ? aRate.compareTo(bRate)
            : bRate.compareTo(aRate);
        });
        break;
      case 'totalBookings':
        _filteredEmployees.sort((a, b) {
          final aBookings = _employeeStatistics[a.uid]?['totalBookings'] as int? ?? 0;
          final bBookings = _employeeStatistics[b.uid]?['totalBookings'] as int? ?? 0;
          return _sortAscending 
            ? aBookings.compareTo(bBookings)
            : bBookings.compareTo(aBookings);
        });
        break;
    }
  }

  // Refresh employees
  Future<void> refreshEmployees() async {
    try {
      AppConfig.log('Refreshing employees');
      await _loadEmployeeData();
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to refresh employees', e);
      _setError('Failed to refresh employees');
    }
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
    AppConfig.log('Disposing EmployeeProvider');
    super.dispose();
  }
}