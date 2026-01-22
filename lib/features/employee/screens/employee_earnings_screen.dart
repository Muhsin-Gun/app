import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../models/booking_model.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmployeeEarningsScreen extends StatefulWidget {
  const EmployeeEarningsScreen({super.key});

  @override
  State<EmployeeEarningsScreen> createState() => _EmployeeEarningsScreenState();
}

class _EmployeeEarningsScreenState extends State<EmployeeEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text(
          'My Earnings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(
                value: 'This Month',
                child: Text('This Month'),
              ),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
              const PopupMenuItem(value: 'All Time', child: Text('All Time')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Earnings Overview Card
          Container(
            margin: EdgeInsets.all(5.w),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Consumer<BookingProvider>(
              builder: (context, provider, _) {
                final earnings = _calculateEarnings(provider.bookings);
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Earnings',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '\$${(earnings['total'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _EarningsStat(
                          label: 'Available',
                          value:
                              '\$${(earnings['available'] ?? 0.0).toStringAsFixed(2)}',
                          color: Colors.white,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _EarningsStat(
                          label: 'Pending',
                          value:
                              '\$${(earnings['pending'] ?? 0.0).toStringAsFixed(2)}',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Earnings'),
              Tab(text: 'History'),
              Tab(text: 'Payouts'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            indicatorColor: theme.colorScheme.primary,
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EarningsTab(selectedPeriod: _selectedPeriod),
                const _HistoryTab(),
                const _PayoutsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateEarnings(List<BookingModel> bookings) {
    final userId = context.read<AuthProvider>().userId;
    final userBookings = bookings
        .where((b) => b.employeeId == userId && b.status == 'completed')
        .toList();

    double total = 0;
    double available = 0;
    double pending = 0;

    for (final booking in userBookings) {
      final amount = booking.totalAmount ?? 0;
      total += amount;

      // Assume 70% available immediately, 30% pending for 30 days
      available += amount * 0.7;
      pending += amount * 0.3;
    }

    return {'total': total, 'available': available, 'pending': pending};
  }
}

class _EarningsStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _EarningsStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}

class _EarningsTab extends StatelessWidget {
  final String selectedPeriod;

  const _EarningsTab({required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final userId = context.read<AuthProvider>().userId;
        final earnings = _calculatePeriodEarnings(
          provider.bookings,
          selectedPeriod,
          userId!,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$selectedPeriod Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),

              // Period Stats
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _PeriodStatItem(
                      icon: Icons.work,
                      label: 'Jobs Completed',
                      value: earnings['jobs'].toString(),
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _PeriodStatItem(
                      icon: Icons.attach_money,
                      label: 'Total Earned',
                      value: '\$${earnings['earned'].toStringAsFixed(2)}',
                      color: theme.colorScheme.primary,
                    ),
                    const Divider(height: 24),
                    _PeriodStatItem(
                      icon: Icons.star,
                      label: 'Average Rating',
                      value: earnings['rating'].toStringAsFixed(1),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Recent Earnings
              Text(
                'Recent Earnings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2.h),

              ...earnings['recentJobs'].map<Widget>((job) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            job['date'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${job['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculatePeriodEarnings(
    List<BookingModel> bookings,
    String period,
    String userId,
  ) {
    final now = DateTime.now();

    DateTime startDate;
    switch (period) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(2020); // All time
    }

    final periodBookings = bookings
        .where(
          (b) =>
              b.employeeId == userId &&
              b.status == 'completed' &&
              b.createdAt!.isAfter(startDate),
        )
        .toList();

    double totalEarned = 0;
    final recentJobs = <Map<String, dynamic>>[];

    for (final booking in periodBookings) {
      totalEarned += booking.totalAmount ?? 0;

      if (recentJobs.length < 5) {
        recentJobs.add({
          'title': booking.productTitle ?? 'Service',
          'date': DateFormat('MMM dd').format(booking.createdAt!),
          'amount': booking.totalAmount ?? 0,
        });
      }
    }

    return {
      'jobs': periodBookings.length,
      'earned': totalEarned,
      'rating': 4.8, // Mock rating
      'recentJobs': recentJobs,
    };
  }
}

class _PeriodStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PeriodStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final userId = context.read<AuthProvider>().userId;
        final completedJobs =
            provider.bookings
                .where((b) => b.employeeId == userId && b.status == 'completed')
                .toList()
              ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        if (completedJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No earnings history yet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(5.w),
          itemCount: completedJobs.length,
          itemBuilder: (context, index) {
            final job = completedJobs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.productTitle ?? 'Service',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(job.createdAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${(job.totalAmount ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }
}

class _PayoutsTab extends StatelessWidget {
  const _PayoutsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock payout data - in real app this would come from a payouts collection
    final payouts = [
      {
        'id': 'PYT001',
        'amount': 245.50,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'completed',
        'method': 'M-Pesa',
      },
      {
        'id': 'PYT002',
        'amount': 189.75,
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'status': 'completed',
        'method': 'Bank Transfer',
      },
      {
        'id': 'PYT003',
        'amount': 312.00,
        'date': DateTime.now().subtract(const Duration(days: 25)),
        'status': 'pending',
        'method': 'M-Pesa',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(5.w),
      itemCount: payouts.length,
      itemBuilder: (context, index) {
        final payout = payouts[index];
        final isCompleted = payout['status'] == 'completed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.schedule,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payout ${payout['id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${(payout['amount'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payout['method']} • ${DateFormat('MMM dd, yyyy').format(payout['date'] as DateTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      payout['status'].toString().toUpperCase(),
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}
