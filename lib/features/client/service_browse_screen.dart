import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';
import 'booking_form_screen.dart';

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
    ServiceCategory(name: 'All', icon: 'apps', color: AppTheme.primaryColor),
    ServiceCategory(name: 'Cleaning', icon: 'cleaning_services', color: AppTheme.primaryColor),
    ServiceCategory(name: 'Plumbing', icon: 'plumbing', color: AppTheme.secondaryColor),
    ServiceCategory(name: 'Electrical', icon: 'electrical_services', color: AppTheme.tertiaryColor),
    ServiceCategory(name: 'Carpentry', icon: 'carpenter', color: AppTheme.warningColor),
    ServiceCategory(name: 'Painting', icon: 'format_paint', color: AppTheme.errorColor),
    ServiceCategory(name: 'Gardening', icon: 'yard', color: AppTheme.successColor),
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
      
      return matchesSearch && matchesCategory && product.isActive;
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
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 48, // Fixed height for web compatibility
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 5.w,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 5.w,
                                ),
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Filter and Sort Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 5.h,
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              onChanged: (value) => _onSortChanged(value!),
                              items: const [
                                DropdownMenuItem(value: 'name', child: Text('Name')),
                                DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                                DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                                DropdownMenuItem(value: 'rating', child: Text('Rating')),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        height: 5.h,
                        width: 5.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _showFilterDialog(context),
                          icon: CustomIconWidget(
                            iconName: 'tune',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 5.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Categories
            Container(
              height: 12.h,
              padding: EdgeInsets.symmetric(vertical: 2.h),
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
                              ? category.color.withValues(alpha: 0.1)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? category.color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: category.icon,
                              color: isSelected 
                                  ? category.color
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              category.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected 
                                    ? category.color
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isSelected 
                                    ? FontWeight.w600
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
                  if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
                  

                  final filteredProducts = _filterAndSortProducts(productProvider.products);

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'search_off',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 15.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No services found',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try adjusting your search or filters',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveBreakpoints.getGridColumns(context),
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 3.w,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return FadeListItem(
                        index: index,
                        child: HoverWidget(
                          child: ServiceCard(
                            product: product,
                            onTap: () => _showServiceDetails(context, product),
                          ),
                        ),
                      );
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

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(
        selectedCategory: _selectedCategory,
        onCategoryChanged: _onCategorySelected,
        categories: _categories,
      ),
    );
  }

  void _showServiceDetails(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsScreen(product: product),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero animation
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'service-image-${product.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(
                    imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: product.title,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      product.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.rating != null)
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'star',
                                color: AppTheme.warningColor,
                                size: 3.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                product.rating!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final List<ServiceCategory> categories;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children: categories.map((category) {
              final isSelected = (selectedCategory.isEmpty && category.name == 'All') ||
                  selectedCategory == category.name;
              
              return GestureDetector(
                onTap: () {
                  onCategoryChanged(category.name);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? category.color.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? category.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: category.icon,
                        color: isSelected 
                            ? category.color
                            : theme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        category.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? category.color
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected 
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class ServiceDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ServiceDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            onPressed: () {
              // Add to favorites
            },
            icon: const CustomIconWidget(iconName: 'favorite_border'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery with Hero animation
            SizedBox(
              height: 30.h,
              child: PageView.builder(
                itemCount: product.imageUrls.length,
                itemBuilder: (context, index) {
                  final imageWidget = CustomImageWidget(
                    imageUrl: product.imageUrls[index],
                    width: double.infinity,
                    height: 30.h,
                    fit: BoxFit.cover,
                    semanticLabel: '${product.title} image ${index + 1}',
                  );
                  // Only first image has Hero for smooth transition
                  if (index == 0) {
                    return Hero(
                      tag: 'service-image-${product.id}',
                      child: imageWidget,
                    );
                  }
                  return imageWidget;
                },
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Rating and Category
                  Row(
                    children: [
                      if (product.rating != null) ...[
                        CustomIconWidget(
                          iconName: 'star',
                          color: AppTheme.warningColor,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Contact provider
                },
                child: const Text('Contact Provider'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Book service
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingFormScreen(product: product),
                    ),
                  );
                },
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Service'),
        content: Text('Book ${product.title} for \$${product.price.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to booking form
            },
            child: const Text('Confirm'),
          ),
        ],
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
