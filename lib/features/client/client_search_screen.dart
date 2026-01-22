import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';

class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  State<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'relevance'; // relevance, price_low, price_high, rating

  final List<String> _categories = [
    'All',
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Landscaping',
    'AC Repair',
    'Appliance Repair',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    var filtered = products.where((product) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.title.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query) &&
            !product.category.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && _selectedCategory != 'All') {
        if (product.category != _selectedCategory) {
          return false;
        }
      }

      // Price filter
      if (product.price < _minPrice || product.price > _maxPrice) {
        return false;
      }

      return true;
    }).toList();

    // Sort results
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default:
        // Keep relevance order (as is)
        break;
    }

    return filtered;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCategory = 'All';
                        _minPrice = 0;
                        _maxPrice = 1000;
                        _sortBy = 'relevance';
                      });
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Category Filter
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category ||
                      (_selectedCategory == null && category == 'All');
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedCategory = category;
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 3.h),

              // Price Range
              Text(
                'Price Range: \$${_minPrice.toInt()} - \$${_maxPrice.toInt()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 1000,
                divisions: 20,
                labels: RangeLabels(
                  '\$${_minPrice.toInt()}',
                  '\$${_maxPrice.toInt()}',
                ),
                onChanged: (values) {
                  setModalState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                  setState(() {});
                },
              ),

              SizedBox(height: 3.h),

              // Sort By
              Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  ChoiceChip(
                    label: const Text('Relevance'),
                    selected: _sortBy == 'relevance',
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _sortBy = 'relevance');
                        setState(() {});
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Price: Low to High'),
                    selected: _sortBy == 'price_low',
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _sortBy = 'price_low');
                        setState(() {});
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Price: High to Low'),
                    selected: _sortBy == 'price_high',
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _sortBy = 'price_high');
                        setState(() {});
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Rating'),
                    selected: _sortBy == 'rating',
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => _sortBy = 'rating');
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = context.watch<ProductProvider>();
    final filteredProducts = _getFilteredProducts(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: 'filter_list', size: 24),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Active Filters Display
          if (_selectedCategory != null && _selectedCategory != 'All' ||
              _minPrice > 0 ||
              _maxPrice < 1000 ||
              _sortBy != 'relevance')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Wrap(
                spacing: 2.w,
                children: [
                  if (_selectedCategory != null && _selectedCategory != 'All')
                    Chip(
                      label: Text(_selectedCategory!),
                      onDeleted: () {
                        setState(() => _selectedCategory = 'All');
                      },
                    ),
                  if (_minPrice > 0 || _maxPrice < 1000)
                    Chip(
                      label: Text('\$${_minPrice.toInt()}-\$${_maxPrice.toInt()}'),
                      onDeleted: () {
                        setState(() {
                          _minPrice = 0;
                          _maxPrice = 1000;
                        });
                      },
                    ),
                  if (_sortBy != 'relevance')
                    Chip(
                      label: Text('Sort: ${_sortBy.replaceAll('_', ' ')}'),
                      onDeleted: () {
                        setState(() => _sortBy = 'relevance');
                      },
                    ),
                ],
              ),
            ),

          SizedBox(height: 2.h),

          // Results Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredProducts.length} service${filteredProducts.length != 1 ? 's' : ''} found',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Results Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'search_off',
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 60,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No services found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Try adjusting your filters',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 3.w,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ServiceCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ProductModel product;

  const _ServiceCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Navigate to service details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${product.title}')),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomImageWidget(
                imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // Details
            Expanded(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        const CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${product.rating?.toStringAsFixed(1) ?? '0.0'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
