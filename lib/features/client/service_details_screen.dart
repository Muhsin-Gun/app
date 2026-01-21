import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_image_widget.dart';
import 'booking_form_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ProductModel product;
  const ServiceDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 45.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'service-image-${product.id}',
                child: CustomImageWidget(
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: 'Detailed image for ${product.title}',
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(backgroundColor: Colors.black26, child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context))),
            ),
            actions: [
              CircleAvatar(backgroundColor: Colors.black26, child: IconButton(icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20), onPressed: () {})),
              const SizedBox(width: 8),
              CircleAvatar(backgroundColor: Colors.black26, child: IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20), onPressed: () {})),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Text(product.category, style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text('4.8', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(' (120+ reviews)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05, end: 0),
                  SizedBox(height: 3.h),
                  Text(product.title, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 1.h),
                  Text('Premium ${product.category} Service', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)).animate().fadeIn(delay: 300.ms),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailInfo(icon: Icons.timer_outlined, label: 'Duration', value: '1-2 hrs'),
                      _DetailInfo(icon: Icons.verified_outlined, label: 'Warranty', value: '30 Days'),
                      _DetailInfo(icon: Icons.shield_outlined, label: 'Insured', value: 'Yes'),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 4.h),
                  Text('Description', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)).animate().fadeIn(delay: 500.ms),
                  SizedBox(height: 1.5.h),
                  Text(product.description, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.6)).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price', style: theme.textTheme.bodySmall),
                Text('\$${product.price}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 24)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookingFormScreen(product: product))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Book Service Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailInfo({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28.w,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
