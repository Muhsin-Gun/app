import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          EmployeeHomePage(),
          EmployeeJobsPage(),
          EmployeeMessagesPage(),
          EmployeeProfilePage(),
        ],
      ),
      bottomNavigationBar: EmployeeBottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
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
                      theme.colorScheme.primary.withValues(alpha: 0.8),
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
                                color: Colors.white.withValues(alpha: 0.9),
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
                    // Stats Cards
                    Consumer<BookingProvider>(
                      builder: (context, bookingProvider, _) {
                        final activeCount = bookingProvider.bookings.where((b) => b.status == 'active' || b.status == 'assigned').length;
                        final completedCount = bookingProvider.bookings.where((b) => b.status == 'completed').length;
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Active Jobs',
                                value: activeCount.toString(),
                                iconName: 'work',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _StatCard(
                                title: 'Completed',
                                value: completedCount.toString(),
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
                      'Priority Jobs',
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
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconName;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.iconName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 6.w,
              ),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysJobsSection extends StatefulWidget {
  const TodaysJobsSection({super.key});

  @override
  State<TodaysJobsSection> createState() => _TodaysJobsSectionState();
}

class _TodaysJobsSectionState extends State<TodaysJobsSection> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings for employee on load
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<BookingProvider>().initializeBookings(authProvider.user!.uid, 'employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading && bookingProvider.bookings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final jobs = bookingProvider.bookings.where((b) => b.status != 'completed' && b.status != 'cancelled').toList();

        if (jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'No active jobs at the moment',
                 style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.dividerColor,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return FadeListItem(
                index: index,
                child: HoverWidget(
                  child: ListTile(
                contentPadding: EdgeInsets.all(4.w),
                leading: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(job.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'work',
                      color: _getStatusColor(job.status),
                      size: 6.w,
                    ),
                  ),
                ),
                title: Text(
                  job.productTitle ?? 'Service',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0.5.h),
                    Text(
                      'Client: ${job.clientName ?? 'Unknown'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (job.address != null)
                    Text(
                      job.address!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: _buildJobAction(context, job, bookingProvider),
                onTap: () {
                  // Navigate to job details
                },
              ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildJobAction(BuildContext context, dynamic job, BookingProvider provider) {
    if (job.status == 'assigned') {
      return ScaleButton(
        onTap: () => provider.updateBookingStatus(job.id, 'active'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (job.status == 'active') {
      return ScaleButton(
        onTap: () => provider.updateBookingStatus(job.id, 'completed'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: _getStatusColor(job.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        job.status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(job.status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppTheme.warningColor;
      case 'assigned': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return AppTheme.successColor;
      default: return Colors.grey;
    }
  }
}

class EmployeeQuickActions extends StatelessWidget {
  const EmployeeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        title: 'Route to Job',
        iconName: 'directions',
        color: AppTheme.successColor,
        onTap: () {
          // Future: Maps integration
        },
      ),
      QuickAction(
        title: 'Check Schedule',
        iconName: 'calendar_month',
        color: AppTheme.primaryColor,
        onTap: () {
          // Future: Calendar view
        },
      ),
      QuickAction(
        title: 'Messages',
        iconName: 'message',
        color: AppTheme.secondaryColor,
        onTap: () {
          // Future: Messaging
        },
      ),
      QuickAction(
        title: 'Support',
        iconName: 'help_outline',
        color: AppTheme.warningColor,
        onTap: () {
          // Future: Support ticket
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
            color: action.color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
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
                color: action.color.withValues(alpha: 0.1),
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
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: CustomIconWidget(
                iconName: 'notifications',
                color: theme.colorScheme.primary,
                size: 4.w,
              ),
            ),
            title: Text(
              activities[index],
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              '${index + 1} hour${index == 0 ? '' : 's'} ago',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'arrow_forward',
              color: theme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          );
        },
      ),
    );
  }
}

class MockJob {
  final String id;
  final String title;
  final String clientName;
  final String address;
  final String time;
  final String status;
  final Color statusColor;

  MockJob({
    required this.id,
    required this.title,
    required this.clientName,
    required this.address,
    required this.time,
    required this.status,
    required this.statusColor,
  });
}

class QuickAction {
  final String title;
  final String iconName;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.iconName,
    required this.color,
    required this.onTap,
  });
}

// Placeholder pages for other tabs
class EmployeeJobsPage extends StatelessWidget {
  const EmployeeJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: const Center(child: Text('My Jobs')),
    );
  }
}

class EmployeeMessagesPage extends StatelessWidget {
  const EmployeeMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Messages')),
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
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // Navigate to settings
                  break;
                case 'logout':
                  _showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
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
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomAvatarWidget(
                    imageUrl: authProvider.userPhotoUrl,
                    fallbackText: authProvider.userName ?? 'Employee',
                    radius: 12.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    authProvider.userName ?? 'Employee',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    authProvider.userEmail ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Service Provider',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            // Profile Options
            Container(
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
                children: [
                  _ProfileOption(
                    iconName: 'person',
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'work',
                    title: 'Job History',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'schedule',
                    title: 'Availability',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'star',
                    title: 'Ratings & Reviews',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'notifications',
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'help',
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _ProfileOption(
                    iconName: 'info',
                    title: 'About',
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (context.mounted) {
                AppRouter.navigateToLogin(context);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final String iconName;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _ProfileOption({
    required this.iconName,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge,
          ),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: theme.colorScheme.onSurfaceVariant,
            size: 4.w,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: theme.dividerColor,
            height: 1,
          ),
      ],
    );
  }
}
