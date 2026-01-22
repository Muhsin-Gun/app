import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
<<<<<<< HEAD
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
=======
import 'package:intl/intl.dart';
import '../../core/theme.dart';
>>>>>>> 3fc94d9 (profile)
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/message_provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
<<<<<<< HEAD
import '../../core/utils/animations.dart';
=======
import '../../models/booking_model.dart';
import 'employee_job_details_screen.dart';
import 'employee_earnings_screen.dart';
import 'employee_profile_edit_screen.dart';
import '../client/client_messages_screen.dart';
>>>>>>> 3fc94d9 (profile)

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
<<<<<<< HEAD
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const _EmployeeJobsView(),
          const _EmployeeMessagesView(),
          const EmployeeProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Jobs',
=======
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${authProvider.userName?.split(' ').first ?? 'Employee'}!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Ready to complete your assigned jobs?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        CustomAvatarWidget(
                          imageUrl: authProvider.userPhotoUrl,
                          fallbackText: authProvider.userName ?? 'Employee',
                          radius: 6.w,
                          onTap: () {
                            // Navigate to profile
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Stats Cards - Connect to real data
                    Consumer<BookingProvider>(
                      builder: (context, bookingProvider, child) {
                        final employeeId = authProvider.currentUser?.uid ?? '';
                        final employeeBookings = bookingProvider.bookings.where((b) => b.employeeId == employeeId).toList();
                        final activeJobs = employeeBookings.where((b) => b.status.toLowerCase() == 'active' || b.status.toLowerCase() == 'assigned').length;
                        final completedJobs = employeeBookings.where((b) => b.status.toLowerCase() == 'completed').length;
                        
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Active Jobs',
                                value: activeJobs.toString(),
                                iconName: 'work',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _StatCard(
                                title: 'Completed',
                                value: completedJobs.toString(),
                                iconName: 'check_circle',
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // Today's Jobs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Jobs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const TodaysJobsSection(),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const EmployeeQuickActions(),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // Recent Activity
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const RecentActivitySection(),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
>>>>>>> 3fc94d9 (profile)
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _EmployeeJobsView extends StatelessWidget {
  const _EmployeeJobsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().userModel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'My Work',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(context),
                SizedBox(height: 3.h),
                const Text(
                  'Assigned Tasks',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          Consumer<BookingProvider>(
            builder: (context, provider, _) {
              final jobs = provider.bookings
                  .where((b) => b.employeeId == user?.uid)
                  .toList();
              if (provider.isLoading && jobs.isEmpty)
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              if (jobs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 64,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No jobs assigned yet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _JobCard(booking: jobs[index])
                      .animate()
                      .fadeIn(delay: (index * 50).ms)
                      .slideX(begin: 0.05, end: 0),
                  childCount: jobs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Jobs', '12', Colors.white),
          _statItem('Rating', '4.9', Colors.white),
          _statItem('Earned', '\$1.2k', Colors.white),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final BookingModel booking;
  const _JobCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.id.substring(0, 8).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            booking.productTitle ?? 'Service',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.address ?? 'No address',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                booking.scheduledDate != null
                    ? DateFormat(
                        'MMM dd, hh:mm a',
                      ).format(booking.scheduledDate!)
                    : 'Now',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Start Job'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeMessagesView extends StatelessWidget {
  const _EmployeeMessagesView();

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          SliverAppBar(
            title: const Text(
              'Inbox',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: false,
          ),
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, _) {
                final conversations = provider.conversations;
                if (provider.isLoading && conversations.isEmpty)
                  return const Center(child: CircularProgressIndicator());
                if (conversations.isEmpty)
                  return const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );

                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (ctx, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final otherUser = conv['otherUser'];
                    final lastMessage = conv['message'];
                    final name = otherUser?.name ?? 'Client';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CustomAvatarWidget(
                        imageUrl: otherUser?.photoUrl,
                        fallbackText: name[0],
                        radius: 28,
=======
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    
    // Filter today's jobs for this employee
    final employeeId = authProvider.currentUser?.uid ?? '';
    final now = DateTime.now();
    final todayBookings = bookingProvider.bookings.where((booking) {
      if (booking.employeeId != employeeId) return false;
      if (booking.scheduledDate == null) return false;
      
      final bookingDate = booking.scheduledDate!;
      return bookingDate.year == now.year &&
             bookingDate.month == now.month &&
             bookingDate.day == now.day &&
             (booking.status.toLowerCase() == 'assigned' || booking.status.toLowerCase() == 'active');
    }).toList();
    
    // Sort by scheduled time
    todayBookings.sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));

    if (todayBookings.isEmpty) {
      return Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'work_outline',
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 50,
              ),
              SizedBox(height: 2.h),
              Text(
                'No jobs scheduled for today',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todayBookings.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final booking = todayBookings[index];
          final statusColor = booking.status.toLowerCase() == 'active' 
              ? AppTheme.primaryColor 
              : AppTheme.successColor;
          
          return ListTile(
            contentPadding: EdgeInsets.all(4.w),
            leading: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'work',
                  color: statusColor,
                  size: 6.w,
                ),
              ),
            ),
            title: Text(
              booking.productTitle ?? 'Service',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.5.h),
                Text(
                  'Client: ${booking.clientName ?? 'Unknown'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  booking.address ?? 'Address not provided',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      DateFormat('hh:mm a').format(booking.scheduledDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
>>>>>>> 3fc94d9 (profile)
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        lastMessage.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        lastMessage.createdAt.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'otherUserId': otherUser?.uid,
                          'otherUserName': name,
                        },
                      ),
                    );
                  },
                );
              },
            ),
<<<<<<< HEAD
=======
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeJobDetailsScreen(booking: booking),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmployeeQuickActions extends StatelessWidget {
  const EmployeeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        title: 'View Earnings',
        iconName: 'attach_money',
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmployeeEarningsScreen()),
          );
        },
      ),
      QuickAction(
        title: 'All Jobs',
        iconName: 'list',
        color: AppTheme.primaryColor,
        onTap: () {
          // Navigate to Jobs tab
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Go to Jobs tab to see all jobs')),
          );
        },
      ),
      QuickAction(
        title: 'Messages',
        iconName: 'message',
        color: AppTheme.secondaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClientMessagesScreen()),
          );
        },
      ),
      QuickAction(
        title: 'Edit Profile',
        iconName: 'edit',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmployeeProfileEditScreen()),
          );
        },
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 3.w,
      childAspectRatio: 2,
      children: actions.map((action) => _QuickActionCard(action: action)).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action.color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: action.iconName,
                color: action.color,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                action.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities = [
      'Completed job for John Doe',
      'Updated status for Plumbing Repair',
      'Received new job assignment',
      'Client message from Jane Smith',
      'Job scheduled for tomorrow',
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
>>>>>>> 3fc94d9 (profile)
          ),
        ],
      ),
    );
  }
}

class EmployeeProfilePage extends StatelessWidget {
  const EmployeeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CustomAvatarWidget(
                    imageUrl: authProvider.userModel?.photoUrl,
                    fallbackText: authProvider.userName ?? 'P',
                    radius: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    authProvider.userName ?? 'Partner',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    authProvider.userEmail ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            _ProfileOption(
              icon: Icons.person_outline_rounded,
              title: 'My Profile',
              subtitle: 'View and edit profile details',
              onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.notifications_none_rounded,
              title: 'Job Alerts',
              subtitle: 'Manage notifications',
              onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Earnings',
              subtitle: 'Payouts and history',
              onTap: () {},
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted)
                    Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

extension on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
