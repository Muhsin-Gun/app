import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../widgets/custom_icon_widget.dart';

class EmployeeEarningsScreen extends StatefulWidget {
  const EmployeeEarningsScreen({super.key});

  @override
  State<EmployeeEarningsScreen> createState() => _EmployeeEarningsScreenState();
}

class _EmployeeEarningsScreenState extends State<EmployeeEarningsScreen> {
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['This Week', 'This Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    // Filter bookings for this employee
    final employeeBookings = bookingProvider.bookings.where((booking) {
      return booking.employeeId == authProvider.currentUser?.uid &&
          booking.status.toLowerCase() == 'completed';
    }).toList();

    // Calculate earnings based on selected period
    final now = DateTime.now();
    final filteredBookings = employeeBookings.where((booking) {
      if (_selectedPeriod == 'This Week') {
        final weekAgo = now.subtract(const Duration(days: 7));
        return booking.scheduledDate != null && booking.scheduledDate!.isAfter(weekAgo);
      } else if (_selectedPeriod == 'This Month') {
        return booking.scheduledDate != null &&
            booking.scheduledDate!.month == now.month &&
            booking.scheduledDate!.year == now.year;
      }
      return true; // All Time
    }).toList();

    final totalEarnings = filteredBookings.fold<double>(
      0,
      (sum, booking) => sum + (booking.totalAmount ?? 0),
    );

    final jobsCompleted = filteredBookings.length;
    final averageEarning = jobsCompleted > 0 ? totalEarnings / jobsCompleted : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _periods.map((period) {
                      final isSelected = period == _selectedPeriod;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = period),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 0 : 1,
                            ),
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              color: isSelected ? theme.colorScheme.primary : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 3.h),
                  // Total Earnings Display
                  Text(
                    'Total Earnings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '\$${totalEarnings.toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Stats Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Jobs Completed',
                      value: jobsCompleted.toString(),
                      icon: 'check_circle',
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _StatCard(
                      title: 'Avg per Job',
                      value: '\$${averageEarning.toStringAsFixed(2)}',
                      icon: 'trending_up',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Earnings Chart
            if (filteredBookings.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      height: 200,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: _buildEarningsChart(filteredBookings, theme),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
            ],

            // Recent Transactions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Export earnings report
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export feature coming soon')),
                          );
                        },
                        child: const Text('Export'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (filteredBookings.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 4.h),
                          CustomIconWidget(
                            iconName: 'account_balance_wallet',
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            size: 60,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No earnings yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Complete jobs to start earning',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length > 10 ? 10 : filteredBookings.length,
                      separatorBuilder: (context, index) => SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[filteredBookings.length - 1 - index];
                        return _TransactionCard(booking: booking);
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsChart(List<BookingModel> bookings, ThemeData theme) {
    // Group bookings by week or month depending on period
    Map<String, double> earningsByPeriod = {};

    for (var booking in bookings) {
      if (booking.scheduledDate != null) {
        String periodKey;
        if (_selectedPeriod == 'This Week') {
          periodKey = DateFormat('EEE').format(booking.scheduledDate!);
        } else if (_selectedPeriod == 'This Month') {
          periodKey = 'Week ${((booking.scheduledDate!.day - 1) ~/ 7) + 1}';
        } else {
          periodKey = DateFormat('MMM').format(booking.scheduledDate!);
        }

        earningsByPeriod[periodKey] = (earningsByPeriod[periodKey] ?? 0) + (booking.totalAmount ?? 0);
      }
    }

    final sortedKeys = earningsByPeriod.keys.toList();
    if (sortedKeys.length > 7) {
      sortedKeys.removeRange(0, sortedKeys.length - 7);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: earningsByPeriod.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: sortedKeys.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: earningsByPeriod[entry.value] ?? 0,
                color: theme.colorScheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      sortedKeys[value.toInt()],
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final BookingModel booking;

  const _TransactionCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const CustomIconWidget(
              iconName: 'attach_money',
              color: Colors.green,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.productTitle ?? 'Service',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  booking.scheduledDate != null
                      ? DateFormat('MMM dd, yyyy').format(booking.scheduledDate!)
                      : 'Date not set',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+\$${booking.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
