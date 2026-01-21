import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['all', 'pending', 'assigned', 'active', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorColor: theme.colorScheme.primary,
          tabs: _filters.map((f) => Tab(text: f.toUpperCase())).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _filters.map((filter) => _BookingListView(filter: filter)).toList(),
      ),
    );
  }
}

class _BookingListView extends StatelessWidget {
  final String filter;
  const _BookingListView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.bookings.where((b) => filter == 'all' || b.status == filter).toList();
        
        if (provider.isLoading && bookings.isEmpty) return const Center(child: CircularProgressIndicator());
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Text('No $filter bookings yet', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.refreshBookings(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _BookingCard(booking: booking).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
            },
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => _BookingDetailsPage(booking: booking))),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.id.substring(0, 8).toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(booking.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(booking.productTitle ?? 'Service', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            SizedBox(height: 1.h),
            _buildInfo(Icons.calendar_today_rounded, DateFormat('MMM dd, yyyy • hh:mm a').format(booking.scheduledDate!), theme),
            _buildInfo(Icons.location_on_rounded, booking.address ?? 'No address', theme),
            if (booking.employeeName != null) _buildInfo(Icons.engineering_rounded, 'Pro: ${booking.employeeName}', theme, color: theme.colorScheme.primary),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: \$${booking.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text, ThemeData theme, {Color? color}) {
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
}

class _BookingDetailsPage extends StatelessWidget {
  final BookingModel booking;
  const _BookingDetailsPage({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(_getStatusIcon(booking.status), size: 48, color: statusColor)),
                  SizedBox(height: 2.h),
                  Text(booking.statusDisplayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: statusColor)),
                  Text('ID: ${booking.id.toUpperCase()}', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            _buildSection(context, 'Service Details', [
              _DetailItem('Service', booking.productTitle ?? 'N/A'),
              _DetailItem('Total Price', '\$${booking.totalAmount}'),
              _DetailItem('Booked On', DateFormat('MMM dd, yyyy').format(booking.createdAt!)),
            ]),
            SizedBox(height: 3.h),
            _buildSection(context, 'Schedule', [
              _DetailItem('Date', DateFormat('EEEE, MMM dd').format(booking.scheduledDate!)),
              _DetailItem('Time', DateFormat('hh:mm a').format(booking.scheduledDate!)),
              _DetailItem('Address', booking.address ?? 'N/A'),
            ]),
            if (booking.employeeName != null) ...[
              SizedBox(height: 3.h),
              _buildSection(context, 'Your Professional', [
                _DetailItem('Name', booking.employeeName!),
                _DetailItem('Status', 'On the way'),
              ]),
            ],
            SizedBox(height: 6.h),
            if (booking.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleCancel(context),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_DetailItem> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        SizedBox(height: 1.5.h),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
          child: Column(children: items),
        ),
      ],
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.history_rounded;
      case 'assigned': return Icons.person_pin_rounded;
      case 'active': return Icons.play_circle_rounded;
      case 'completed': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.info_rounded;
    }
  }

  void _handleCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('This will remove your scheduled appointment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              context.read<BookingProvider>().updateBookingStatus(booking.id, 'cancelled');
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
