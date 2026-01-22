import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';

class AdminProductsManagementScreen extends StatefulWidget {
  const AdminProductsManagementScreen({super.key});

  @override
  State<AdminProductsManagementScreen> createState() => _AdminProductsManagementScreenState();
}

class _AdminProductsManagementScreenState extends State<AdminProductsManagementScreen> {
  String _searchQuery = '';
  String _filterCategory = 'All';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = context.watch<ProductProvider>();

    // Filter products
    var filteredProducts = productProvider.products.where((product) {
      if (_searchQuery.isNotEmpty) {
        if (!product.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_filterCategory != 'All' && product.category != _filterCategory) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: 'add', size: 24),
            onPressed: () {
              _showAddEditProductDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                SizedBox(height: 2.h),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _filterCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _filterCategory = category);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'inventory_2',
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 60,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No products found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        onEdit: () => _showAddEditProductDialog(product: product),
                        onDelete: () => _deleteProduct(product),
                        onToggleStatus: () => _toggleProductStatus(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductDialog({ProductModel? product}) {
    final isEdit = product != null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Use this dialog to ${isEdit ? 'edit' : 'create'} a product with all details including images, pricing, and availability.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              const Text(
                'This will include:\n• Title & description\n• Category selection\n• Price setting\n• Image upload\n• Availability toggle',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete product
              final success = await context.read<ProductProvider>().deleteProduct(product.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.title} deleted successfully')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete product'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(ProductModel product) async {
    final newStatus = !product.isAvailable;
    final success = await context.read<ProductProvider>().updateProductStatus(
      product.id,
      newStatus,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} ${newStatus ? 'activated' : 'deactivated'}'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update product status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 4.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.isAvailable ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: product.isAvailable ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onEdit,
                  child: Row(
                    children: [
                      const CustomIconWidget(iconName: 'edit', size: 20),
                      SizedBox(width: 2.w),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onToggleStatus,
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: product.isAvailable ? 'visibility_off' : 'visibility',
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(product.isAvailable ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: Row(
                    children: [
                      const CustomIconWidget(iconName: 'delete', color: Colors.red, size: 20),
                      SizedBox(width: 2.w),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
