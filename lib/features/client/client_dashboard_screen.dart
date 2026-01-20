import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/booking_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_image_widget.dart';
import 'service_browse_screen.dart';
import 'client_bookings_screen.dart';

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
          ClientHomePage(),
          ClientBrowsePage(),
          ClientBookingsPage(),
          ClientMessagesPage(),
          ClientProfilePage(),
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
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'search',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search services...',
                                      border: InputBorder.none,
                                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Container(
                          height: 6.h,
                          width: 6.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'notifications_outlined',
                                color: theme.colorScheme.onSurface,
                                size: 24,
                              ),
                              Positioned(
                                top: 1.h,
                                right: 1.5.w,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Location
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'San Francisco, CA',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color: theme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Welcome Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${authProvider.userName?.split(' ').first ?? 'User'}!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'What service do you need today?',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // Service Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Service Categories',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              SizedBox(
                height: 12.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _serviceCategories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 3.w),
                  itemBuilder: (context, index) {
                    final category = _serviceCategories[index];
                    return _CategoryCard(category: category);
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // Featured Services
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Services',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.h),

              SizedBox(
                height: 28.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _featuredServices.length,
                  separatorBuilder: (context, index) => SizedBox(width: 3.w),
                  itemBuilder: (context, index) {
                    final service = _featuredServices[index];
                    return _ServiceCard(service: service);
                  },
                ),
              ),

              SizedBox(height: 3.h),

              // Recent Bookings
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Recent Bookings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  final recentBookings = bookingProvider.bookings.take(3).toList();
                  
                  if (recentBookings.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'assignment',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 12.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No bookings yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Book your first service to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: recentBookings.length,
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      final booking = recentBookings[index];
                      return _BookingCard(booking: booking);
                    },
                  );
                },
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 20.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: category['icon'],
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            category['name'],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 75.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CustomImageWidget(
                  imageUrl: service['image'],
                  width: 75.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                  semanticLabel: service['title'],
                ),
              ),
              Positioned(
                top: 1.h,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service['discount'],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  service['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          service['rating'].toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      service['price'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;

  const _BookingCard({required this.booking});

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
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getStatusIcon(booking.status),
                color: _getStatusColor(booking.status),
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.productTitle ?? 'Service',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  booking.statusDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            booking.timeSinceCreation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return 'pending';
      case 'assigned':
        return 'assigned';
      case 'active':
        return 'active';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'info';
    }
  }
}

// Mock data
final List<Map<String, dynamic>> _serviceCategories = [
  {'name': 'Cleaning', 'icon': 'cleaning_services'},
  {'name': 'Plumbing', 'icon': 'plumbing'},
  {'name': 'Electrical', 'icon': 'electrical_services'},
  {'name': 'Carpentry', 'icon': 'carpenter'},
  {'name': 'Painting', 'icon': 'format_paint'},
];

final List<Map<String, dynamic>> _featuredServices = [
  {
    'title': 'Premium Home Cleaning',
    'description': 'Professional deep cleaning service for your entire home',
    'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
    'rating': 4.8,
    'price': '\$89.99',
    'discount': '20% OFF',
  },
  {
    'title': 'Expert Plumbing Services',
    'description': '24/7 emergency plumbing repairs and installations',
    'image': 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
    'rating': 4.9,
    'price': '\$75.00',
    'discount': '15% OFF',
  },
];

// Placeholder pages for other client sections
class ClientBrowsePage extends StatelessWidget {
  const ClientBrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServiceBrowseScreen();
  }
}

class ClientBookingsPage extends StatelessWidget {
  const ClientBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientBookingsScreen();
  }
}

class ClientMessagesPage extends StatelessWidget {
  const ClientMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(
        child: Text('Messages - Coming Soon'),
      ),
    );
  }
}

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: 'logout'),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (context.mounted) {
                AppRouter.navigateToLogin(context);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile - Coming Soon'),
      ),
    );
  }
}