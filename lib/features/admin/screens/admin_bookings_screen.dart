import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../providers/employee_provider.dart';
import '../../../../models/booking_model.dart';
import '../../../../models/user_model.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            child: Row(
              children: [
                _FilterBadge(label: 'All', isSelected: _selectedFilter == 'all', onTap: () => setState(() => _selectedFilter = 'all')),
                SizedBox(width: 3.w),
                _FilterBadge(label: 'Pending', isSelected: _selectedFilter == 'pending', onTap: () => setState(() => _selectedFilter = 'pending')),
                SizedBox(width: 3.w),
                _FilterBadge(label: 'Assigned', isSelected: _selectedFilter == 'assigned', onTap: () => setState(() => _selectedFilter = 'assigned')),
                SizedBox(width: 3.w),
                _FilterBadge(label: 'Active', isSelected: _selectedFilter == 'active', onTap: () => setState(() => _selectedFilter = 'active')),
                SizedBox(width: 3.w),
                _FilterBadge(label: 'Completed', isSelected: _selectedFilter == 'completed', onTap: () => setState(() => _selectedFilter = 'completed')),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, _) {
                final bookings = provider.bookings.where((b) => _selectedFilter == 'all' || b.status == _selectedFilter).toList();
                
                if (provider.isLoading && bookings.isEmpty) return const Center(child: CircularProgressIndicator());
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No $_selectedFilter bookings', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _AdminBookingCard(booking: booking).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterBadge({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
          boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  const _AdminBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking.id.substring(0, 8).toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(booking.statusDisplayName.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(booking.productTitle ?? 'Service', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 1.h),
          _buildInfo(context, Icons.person_rounded, 'Client: ${booking.clientName ?? 'User'}'),
          _buildInfo(context, Icons.location_on_rounded, booking.address ?? 'No address'),
          _buildInfo(context, Icons.calendar_today_rounded, booking.scheduledDate != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(booking.scheduledDate!) : 'Unscheduled'),
          if (booking.employeeName != null)
            _buildInfo(context, Icons.engineering_rounded, 'Pro: ${booking.employeeName}', color: theme.colorScheme.primary),
          
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: \$${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  if (booking.status == 'pending')
                    TextButton(onPressed: () => _handleCancel(context), child: const Text('Cancel', style: TextStyle(color: Colors.red))),
                  if (booking.status == 'pending' || booking.status == 'assigned')
                    ElevatedButton(
                      onPressed: () => _showAssignDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(booking.employeeId == null ? 'Assign' : 'Reassign'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, IconData icon, String text, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color ?? theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _handleCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          ElevatedButton(
            onPressed: () {
              context.read<BookingProvider>().updateBookingStatus(booking.id, 'cancelled');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignEmployeeSheet(booking: booking),
    );
  }
}

class _AssignEmployeeSheet extends StatelessWidget {
  final BookingModel booking;
  const _AssignEmployeeSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeeProvider = context.watch<EmployeeProvider>();

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Professional', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          SizedBox(height: 1.h),
          Text('Assigning for ${booking.productTitle}', style: theme.textTheme.bodyMedium),
          SizedBox(height: 3.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 50.h),
            child: employeeProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: employeeProvider.employees.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final employee = employeeProvider.employees[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, child: Text(employee.name[0])),
                      title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(employee.email),
                      trailing: const Icon(Icons.add_circle_outline_rounded),
                      onTap: () {
                        context.read<BookingProvider>().assignEmployee(booking.id, employee.uid, employee.name);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned to ${employee.name}')));
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
