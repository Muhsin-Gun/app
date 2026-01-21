import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/message_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_image_widget.dart';
import 'service_browse_screen.dart';
import 'client_bookings_screen.dart';
import 'booking_form_screen.dart';
import 'service_details_screen.dart';
import '../../models/product_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
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
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          ClientHomePage(onViewAll: () => _onBottomNavTap(1)),
          const ClientBrowsePage(),
          const ClientBookingsPage(),
          const ClientMessagesPage(),
          const ClientProfilePage(),
        ],
      ),
      bottomNavigationBar: ClientBottomBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}

class ClientHomePage extends StatelessWidget {
  final VoidCallback onViewAll;
  const ClientHomePage({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context.read<BookingProvider>().refreshBookings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${authProvider.userName?.split(' ').first ?? 'User'}!',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.primary),
                            SizedBox(width: 4),
                            Text('Nairobi, Kenya', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                    CustomAvatarWidget(
                      imageUrl: authProvider.userPhotoUrl,
                      fallbackText: authProvider.userName ?? 'U',
                      radius: 28,
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                SizedBox(height: 3.h),

                // Search Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for services...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                SizedBox(height: 4.h),

                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    TextButton(onPressed: onViewAll, child: const Text('View All')),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: 1.5.h),
                const CategorySection().animate().fadeIn(delay: 300.ms),

                SizedBox(height: 4.h),

                // Featured Services
                Text('Top Services', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)).animate().fadeIn(delay: 400.ms),
                SizedBox(height: 2.h),
                const FeaturedServicesSection().animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

                SizedBox(height: 4.h),

                // Recent Bookings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    TextButton(onPressed: () {}, child: const Text('See History')),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                SizedBox(height: 1.5.h),
                const RecentBookingsSection().animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        return SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _CategoryItem(
                name: cat,
                icon: _getIconForCategory(cat),
                color: _getColorForCategory(index),
              ).animate().fadeIn(delay: (index * 100).ms).scale();
            },
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'cleaning': return Icons.cleaning_services_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'electrical': return Icons.electrical_services_rounded;
      case 'carpentry': return Icons.foundation_rounded;
      case 'painting': return Icons.format_paint_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.pink, Colors.teal];
    return colors[index % colors.length];
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const _CategoryItem({required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 1.h),
        Text(name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class FeaturedServicesSection extends StatelessWidget {
  const FeaturedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.getFeaturedProducts(limit: 5);
        if (products.isEmpty) return const SizedBox.shrink();
        
        return SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ServiceCard(product: product);
            },
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ProductModel product;
  const _ServiceCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailsScreen(product: product))),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 70.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CustomImageWidget(imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '', width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(product.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.description, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 1.h),
                  Text(product.formattedPrice, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentBookingsSection extends StatelessWidget {
  const RecentBookingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final bookings = provider.bookings.take(3).toList();
        if (bookings.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ListTile(
                contentPadding: EdgeInsets.all(4.w),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
                ),
                title: Text(booking.productTitle ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(booking.statusDisplayName, style: TextStyle(color: _getStatusColor(booking.status), fontWeight: FontWeight.bold, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

class ClientBrowsePage extends StatelessWidget {
  const ClientBrowsePage({super.key});
  @override
  Widget build(BuildContext context) => const ServiceBrowseScreen();
}

class ClientBookingsPage extends StatelessWidget {
  const ClientBookingsPage({super.key});
  @override
  Widget build(BuildContext context) => const ClientBookingsScreen();
}

class ClientMessagesPage extends StatelessWidget {
  const ClientMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Connect', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: false),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          final conversations = provider.conversations;
          if (provider.isLoading && conversations.isEmpty) return const Center(child: CircularProgressIndicator());
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text('Your conversations will appear here', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final MessageModel lastMessage = conv['message'];
              final UserModel? otherUser = conv['otherUser'];
              final int unreadCount = conv['unreadCount'] ?? 0;
              final name = otherUser?.name ?? 'Partner';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomAvatarWidget(
                  imageUrl: otherUser?.photoUrl,
                  fallbackText: name[0],
                  radius: 28,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(lastMessage.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(_formatTime(lastMessage.createdAt), style: theme.textTheme.bodySmall),
                onTap: () {
                  final authProvider = context.read<AuthProvider>();
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'otherUserId': otherUser?.uid ?? (lastMessage.senderId == authProvider.userId ? lastMessage.receiverId : lastMessage.senderId),
                      'otherUserName': name,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Space', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  CustomAvatarWidget(imageUrl: authProvider.userPhotoUrl, fallbackText: authProvider.userName ?? 'U', radius: 36),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authProvider.userName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                        Text(authProvider.currentUser?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            _buildSection(theme, 'Experience', [
              _ProfileItem(icon: Icons.dark_mode_rounded, title: 'Dark Mode', trailing: Switch(value: theme.brightness == Brightness.dark, onChanged: (v) => authProvider.toggleTheme())),
              _ProfileItem(icon: Icons.notifications_rounded, title: 'Notifications', onTap: () {}),
            ]),
            SizedBox(height: 2.h),
            _buildSection(theme, 'Account', [
              _ProfileItem(icon: Icons.security_rounded, title: 'Security', onTap: () {}),
              _ProfileItem(icon: Icons.logout_rounded, title: 'Logout', color: Colors.red, showArrow: false, onTap: () => _handleLogout(context)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<_ProfileItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(title.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2))),
        Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
          child: Column(children: items),
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) AppRouter.navigateToLogin(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;
  final bool showArrow;
  const _ProfileItem({required this.icon, required this.title, this.onTap, this.trailing, this.color, this.showArrow = true});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: trailing ?? (showArrow ? const Icon(Icons.chevron_right_rounded) : null),
    );
  }
}
