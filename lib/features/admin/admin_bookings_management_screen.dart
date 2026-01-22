import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../models/booking_model.dart';

class AdminBookingsManagementScreen extends StatefulWidget {
  const AdminBookingsManagementScreen({super.key});

  @override
  State<AdminBookingsManagementScreen> createState() => _AdminBookingsManagementScreenState();
}

class _AdminBookingsManagementScreenState extends State<AdminBookingsManagementScreen> {
  String _statusFilter = 'All';

  final List<String> _statuses = [
    'All',
    'Pending',
    'Assigned',
    'Active',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProvider = context.watch<BookingProvider>();

    // Filter bookings by status
    var filteredBookings = bookingProvider.bookings.where((booking) {
      if (_statusFilter == 'All') return true;
      return booking.status.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    // Sort by date (newest first)
    filteredBookings.sort((a, b) {
      if (a.scheduledDate == null) return 1;
      if (b.scheduledDate == null) return -1;
      return b.scheduledDate!.compareTo(a.scheduledDate!);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = _statusFilter == status;
                final count = status == 'All'
                    ? bookingProvider.bookings.length
                    : bookingProvider.bookings.where((b) => b.status.toLowerCase() == status.toLowerCase()).length;

                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    label: Text('$status ($count)'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _statusFilter = status);
                    },
                  ),
                );
              },
            ),
          ),

          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'event_busy',
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 60,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No bookings found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _BookingCard(
                        booking: booking,
                        onAssign: () => _showAssignEmployeeDialog(booking),
                        onCancel: () => _cancelBooking(booking),
                        onViewDetails: () => _showBookingDetails(booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAssignEmployeeDialog(BookingModel booking) {
    final employeeProvider = context.read<EmployeeProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign employee to: ${booking.productTitle}'),
            SizedBox(height: 2.h),
            if (employeeProvider.employees.isEmpty)
              const Text('No employees available')
            else
              ...employeeProvider.employees.map((employee) {
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text(employee.email),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    // Assign employee
                    final success = await context.read<BookingProvider>().assignEmployee(
                      booking.id,
                      employee.uid,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Assigned to ${employee.name}')),
                      );
                    }
                  },
                );
              }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking for ${booking.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<BookingProvider>().updateBookingStatus(
                booking.id,
                'cancelled',
              );
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Service', booking.productTitle ?? 'N/A'),
              _DetailRow('Client', booking.clientName ?? 'N/A'),
              _DetailRow('Phone', booking.phoneNumber ?? 'N/A'),
              _DetailRow('Address', booking.address ?? 'N/A'),
              _DetailRow(
                'Date',
                booking.scheduledDate != null
                    ? DateFormat('MMM dd, yyyy • hh:mm a').format(booking.scheduledDate!)
                    : 'N/A',
              ),
              _DetailRow('Amount', '\$${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
              _DetailRow('Status', booking.status),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(booking.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onAssign;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;

  const _BookingCard({
    required this.booking,
    required this.onAssign,
    required this.onCancel,
    required this.onViewDetails,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Client: ${booking.clientName ?? 'Unknown'}',
                style: theme.textTheme.bodyMedium,
              ),
              if (booking.scheduledDate != null) ...[
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    const CustomIconWidget(iconName: 'schedule', size: 16),
                    SizedBox(width: 1.w),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(booking.scheduledDate!),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (booking.status.toLowerCase() == 'pending')
                        TextButton.icon(
                          onPressed: onAssign,
                          icon: const CustomIconWidget(iconName: 'person_add', size: 18),
                          label: const Text('Assign'),
                        ),
                      if (booking.status.toLowerCase() != 'completed' &&
                          booking.status.toLowerCase() != 'cancelled')
                        IconButton(
                          onPressed: onCancel,
                          icon: const CustomIconWidget(
                            iconName: 'cancel',
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
