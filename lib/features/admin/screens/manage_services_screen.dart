import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/product_model.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/utils/animations.dart';
import '../../../../utils/image_helpers.dart';
import '../../../../widgets/custom_icon_widget.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Cleaning';
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isEditing = false;
  String? _editingProductId;

  final List<String> _categories = ['Cleaning', 'Plumbing', 'Electrical', 'Beauty', 'Moving'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _descController.clear();
    _selectedCategory = 'Cleaning';
    _selectedImageBytes = null;
    _selectedImageName = null;
    _isEditing = false;
    _editingProductId = null;
  }

  Future<void> _pickImage() async {
    final image = await ImageHelpers.pickImageFromGallery();
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = image.name;
      });
    }
  }

  Future<void> _saveService() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name and price'))
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final authProvider = context.read<AuthProvider>();
    
    bool success = false;
    
    if (_isEditing && _editingProductId != null) {
      success = await productProvider.updateProduct(
        _editingProductId!,
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
      );
    } else {
      if (_selectedImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image'))
        );
        return;
      }
      
      success = await productProvider.createProduct(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        createdBy: authProvider.userId ?? 'admin',
        imageBytes: _selectedImageBytes!,
        imageName: _selectedImageName!,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Service Updated' : 'Service Added'))
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(productProvider.errorMessage ?? 'Operation failed'))
      );
    }
  }

  void _showServiceForm({ProductModel? product}) {
    if (product != null) {
      _isEditing = true;
      _editingProductId = product.id;
      _nameController.text = product.title;
      _priceController.text = product.price.toString();
      _descController.text = product.description;
      _selectedCategory = product.category;
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: 85.h,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Service' : 'Add New Service',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      // Image Picker
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final image = await ImageHelpers.pickImageFromGallery();
                            if (image != null) {
                              final bytes = await image.readAsBytes();
                              setModalState(() {
                                _selectedImageBytes = bytes;
                                _selectedImageName = image.name;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              image: _selectedImageBytes != null
                                  ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                                  : (product != null && product.imageUrls.isNotEmpty
                                      ? DecorationImage(image: NetworkImage(product.imageUrls.first), fit: BoxFit.cover)
                                      : null),
                            ),
                            child: (_selectedImageBytes == null && (product == null || product.imageUrls.isEmpty))
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                      SizedBox(height: 1.h),
                                      const Text('Tap to upload image', style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                                : Container(
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.all(8),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.edit, color: AppColors.primary),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Service Name',
                          hintText: 'e.g. Master Plumbing',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                          hintText: 'e.g. 50.00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => _selectedCategory = v!),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What does this service include?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Consumer<ProductProvider>(
                        builder: (context, provider, _) => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _saveService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_isEditing ? 'Update Service' : 'Create Service'),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showServiceForm(),
        label: const Text('New Service', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final products = productProvider.allProducts;

          if (productProvider.isLoading && products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomIconWidget(iconName: 'business', size: 64, color: Colors.grey),
                  SizedBox(height: 2.h),
                  const Text('No services yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Add your first specialized service above', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productProvider.refreshProducts(),
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return FadeListItem(
                  index: index,
                  child: HoverWidget(
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/150',
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 20.w,
                                  height: 20.w,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    product.category,
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showServiceForm(product: product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _confirmDelete(product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to remove "${product.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ProductProvider>().deleteProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service Deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
