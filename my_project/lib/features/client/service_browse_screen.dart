import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';
import 'service_details_screen.dart';
import '../../core/theme.dart';

class ServiceBrowseScreen extends StatefulWidget {
  const ServiceBrowseScreen({super.key});

  @override
  State<ServiceBrowseScreen> createState() => _ServiceBrowseScreenState();
}

class _ServiceBrowseScreenState extends State<ServiceBrowseScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  String _sortBy = 'name';
  final TextEditingController _searchController = TextEditingController();

  final List<ServiceCategory> _categories = [
    ServiceCategory(name: 'All', icon: 'grid_view', color: Colors.indigo),
    ServiceCategory(name: 'Cleaning', icon: 'cleaning_services', color: Colors.blue),
    ServiceCategory(name: 'Plumbing', icon: 'plumbing', color: Colors.red),
    ServiceCategory(name: 'Electrical', icon: 'electrical_services', color: Colors.orange),
    ServiceCategory(name: 'Beauty', icon: 'face', color: Colors.pink),
    ServiceCategory(name: 'Moving', icon: 'local_shipping', color: Colors.green),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category == 'All' ? '' : category;
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
  }

  List<ProductModel> _filterAndSortProducts(List<ProductModel> products) {
    var filtered = products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory.isEmpty ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort products
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Find Services', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
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
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'What are you looking for?',
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
            
            // Categories
            Container(
              height: 10.h,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = (_selectedCategory.isEmpty && category.name == 'All') ||
                      _selectedCategory == category.name;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => _onCategorySelected(category.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected 
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected 
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Services Grid
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  if (productProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredProducts = _filterAndSortProducts(productProvider.products);

                  if (filteredProducts.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 4.w,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ServiceGridCard(product: product)
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('No services found', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Try adjusting your search or category'),
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
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ServiceDetailsScreen(product: product))
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CustomImageWidget(
                  imageUrl: product.imageUrl,
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
                  Text(
                    product.title, 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}', 
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)
                      ),
                      if (product.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                            Text(
                              ' ${product.rating!.toStringAsFixed(1)}', 
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)
                            ),
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

class ServiceCategory {
  final String name;
  final String icon;
  final Color color;

  ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}
