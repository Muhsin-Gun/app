import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';
import 'service_details_screen.dart';

class ServiceBrowseScreen extends StatefulWidget {
  const ServiceBrowseScreen({super.key});

  @override
  State<ServiceBrowseScreen> createState() => _ServiceBrowseScreenState();
}

class _ServiceBrowseScreenState extends State<ServiceBrowseScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Plumbing', 'icon': Icons.plumbing_rounded},
    {'name': 'Electrical', 'icon': Icons.electrical_services_rounded},
    {'name': 'Beauty', 'icon': Icons.face_rounded},
    {'name': 'Moving', 'icon': Icons.local_shipping_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),

          // Categories chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(cat['name']),
                    avatar: Icon(cat['icon'], size: 16, color: isSelected ? Colors.white : theme.colorScheme.primary),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedCategory = cat['name']),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),

          // Services Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                final products = provider.products.where((p) {
                  final matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (provider.isLoading && products.isEmpty) return const Center(child: CircularProgressIndicator());
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        const Text('No services found', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 4.w,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ServiceGridCard(product: product).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
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

class _ServiceGridCard extends StatelessWidget {
  final ProductModel product;
  const _ServiceGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetailsScreen(product: product))),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CustomImageWidget(
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: 'Image for ${product.title}',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                          Text(' 4.8', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
