import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/message_provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../core/utils/animations.dart';

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
