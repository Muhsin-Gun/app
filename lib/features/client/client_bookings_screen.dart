import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/booking_model.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    switch (_selectedFilter) {
      case 'pending':
        return bookings.where((b) => b.status == 'pending').toList();
      case 'assigned':
        return bookings.where((b) => b.status == 'assigned').toList();
      case 'active':
        return bookings.where((b) => b.status == 'active').toList();
      case 'completed':
        return bookings.where((b) => b.status == 'completed').toList();
      case 'cancelled':
        return bookings.where((b) => b.status == 'cancelled').toList();
      default:
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Bookings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Refresh bookings
                          context.read<BookingProvider>().refreshBookings();
                        },
                        icon: const CustomIconWidget(iconName: 'refresh'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Filter Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    onTap: (index) {
                      final filters = ['all', 'pending', 'assigned', 'active', 'completed'];
                      setState(() {
                        _selectedFilter = filters[index];
                      });
                    },
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Assigned'),
                      Tab(text: 'Active'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ],
              ),
            ),

            // Bookings List
            Expanded(
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  if (bookingProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredBookings = _filterBookings(bookingProvider.bookings);

                  if (filteredBookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'assignment',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 15.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _selectedFilter == 'all' 
                                ? 'No bookings yet'
                                : 'No ${_selectedFilter} bookings',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _selectedFilter == 'all'
                                ? 'Book your first service to get started'
                                : 'Check other tabs for your bookings',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 3.w),
                        child: BookingCard(
                          booking: booking,
                          onTap: () => _showBookingDetails(context, booking),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: booking),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.productTitle ?? 'Service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Details
            if (booking.scheduledDate != null) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year} at ${booking.scheduledDate!.hour}:${booking.scheduledDate!.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
            
            if (booking.employeeName != null) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Assigned to: ${booking.employeeName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
            
            if (booking.totalAmount != null) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'money',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '\$${booking.totalAmount!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
            
            // Created Date
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Booked ${booking.timeSinceCreation}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'assigned':
        return AppTheme.primaryColor;
      case 'active':
        return AppTheme.secondaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (booking.canBeCancelled)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'cancel':
                    _showCancelDialog(context);
                    break;
                  case 'reschedule':
                    _showRescheduleDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (booking.canBeCancelled)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel),
                      title: Text('Cancel Booking'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (booking.canBeCancelled)
                  const PopupMenuItem(
                    value: 'reschedule',
                    child: ListTile(
                      leading: Icon(Icons.schedule),
                      title: Text('Reschedule'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(booking.status),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: _getStatusIcon(booking.status),
                    color: _getStatusColor(booking.status),
                    size: 10.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    booking.statusDisplayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _getStatusColor(booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Service Details
            _buildDetailSection(
              context,
              'Service Details',
              [
                _DetailItem('Service', booking.productTitle ?? 'N/A'),
                if (booking.totalAmount != null)
                  _DetailItem('Amount', '\$${booking.totalAmount!.toStringAsFixed(2)}'),
                _DetailItem('Booking ID', booking.id),
                _DetailItem('Booked On', booking.createdAt.toString().split('.')[0]),
              ],
            ),

            SizedBox(height: 3.h),

            // Schedule Details
            if (booking.scheduledDate != null)
              _buildDetailSection(
                context,
                'Schedule',
                [
                  _DetailItem(
                    'Date & Time',
                    '${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year} at ${booking.scheduledDate!.hour}:${booking.scheduledDate!.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),

            SizedBox(height: 3.h),

            // Service Provider
            if (booking.employeeName != null)
              _buildDetailSection(
                context,
                'Service Provider',
                [
                  _DetailItem('Name', booking.employeeName!),
                ],
              ),

            SizedBox(height: 3.h),

            // Contact Information
            _buildDetailSection(
              context,
              'Contact Information',
              [
                _DetailItem('Client', booking.clientName ?? 'N/A'),
                if (booking.phoneNumber != null)
                  _DetailItem('Phone', booking.phoneNumber!),
                if (booking.address != null)
                  _DetailItem('Address', booking.address!),
              ],
            ),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              SizedBox(height: 3.h),
              _buildDetailSection(
                context,
                'Additional Notes',
                [
                  _DetailItem('Notes', booking.notes!),
                ],
              ),
            ],

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<_DetailItem> items,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 25.w,
                      child: Text(
                        '${item.label}:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'assigned':
        return AppTheme.primaryColor;
      case 'active':
        return AppTheme.secondaryColor;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'assigned':
        return 'assignment_ind';
      case 'active':
        return 'work';
      case 'completed':
        return 'check_circle';
      case 'cancelled':
        return 'cancel';
      default:
        return 'info';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Cancel booking logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: const Text('Contact customer service to reschedule your booking.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}
