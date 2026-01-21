import 'dart:typed_bytes';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/product_model.dart';
import '../../../../utils/image_helpers.dart';
import '../../../../widgets/custom_image_widget.dart';

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

  Future<void> _saveService() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in name and price')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Service Updated' : 'Service Added')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(productProvider.errorMessage ?? 'Operation failed')));
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
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, MediaQuery.of(context).viewInsets.bottom + 4.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                SizedBox(height: 3.h),
                Text(_isEditing ? 'Edit Service' : 'Add New Service', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                SizedBox(height: 3.h),
                GestureDetector(
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      image: _selectedImageBytes != null
                          ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                          : (product != null && product.imageUrls.isNotEmpty ? DecorationImage(image: NetworkImage(product.imageUrls.first), fit: BoxFit.cover) : null),
                    ),
                    child: (_selectedImageBytes == null && (product == null || product.imageUrls.isEmpty))
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
                              SizedBox(height: 1.h),
                              const Text('Upload Cover Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 3.h),
                _buildField('Service Name', _nameController, Icons.work_outline_rounded),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(child: _buildField('Price', _priceController, Icons.payments_outlined, isNumber: true, prefix: '$')),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => _selectedCategory = v!),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildField('Description', _descController, Icons.description_outlined, maxLines: 3),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _saveService,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text(_isEditing ? 'Update Service' : 'Create Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, String? prefix, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Services', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceForm(),
        label: const Text('New Service'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final products = provider.allProducts;
          if (provider.isLoading && products.isEmpty) return const Center(child: CircularProgressIndicator());
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 64, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  const Text('No services found', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.refreshProducts(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: CustomImageWidget(
                          imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                          height: 18.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: 'Service image for ${product.title}',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                                  child: Text(product.category, style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(product.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(onPressed: () => _showServiceForm(product: product), icon: const Icon(Icons.edit_rounded, size: 18), label: const Text('Edit')),
                                SizedBox(width: 4.w),
                                TextButton.icon(
                                  onPressed: () => _handleDelete(context, product),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Remove "${product.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
