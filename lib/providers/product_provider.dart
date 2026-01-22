import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Private variables
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  // Getters
  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  int get productCount => _filteredProducts.length;
  int get totalProductCount => _products.length;

  ProductProvider() {
    _initializeProducts();
  }

  // Initialize products stream
  void _initializeProducts() {
    try {
      AppConfig.log('Initializing ProductProvider');
      
      _firestoreService.getProductsStream().listen(
        (products) {
          _products = products;
          _updateCategories();
          _applyFilters();
          _clearError();
          notifyListeners();
        },
        onError: (error) {
          AppConfig.logError('Error in products stream', error);
          _setError('Failed to load products');
        },
      );
      
      AppConfig.log('ProductProvider initialized successfully');
    } catch (e) {
      AppConfig.logError('Failed to initialize ProductProvider', e);
      _setError('Failed to initialize products');
    }
  }

  // Create new product
  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required String createdBy,
    required Uint8List imageBytes,
    required String imageName,
    List<String> tags = const [],
    String? duration,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Creating product: $title');
      
      // Upload image to Cloudinary
      final imageUrl = await _cloudinaryService.uploadImage(imageBytes, imageName);
      if (imageUrl == null) {
        _setError('Failed to upload product image');
        return false;
      }
      
      // Create product model
      final product = ProductModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        price: price,
        imageUrls: [imageUrl],
        category: category,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        tags: tags,
        duration: duration,
      );
      
      // Save to Firestore
      final productId = await _firestoreService.createProduct(product);
      
      AppConfig.log('Product created successfully with ID: $productId');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to create product', e);
      _setError('Failed to create product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<bool> updateProduct(
    String productId, {
    String? title,
    String? description,
    double? price,
    String? category,
    Uint8List? imageBytes,
    String? imageName,
    List<String>? tags,
    String? duration,
    bool? isActive,
    bool? isAvailable,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating product: $productId');
      
      final updateData = <String, dynamic>{};
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (category != null) updateData['category'] = category;
      if (tags != null) updateData['tags'] = tags;
      if (duration != null) updateData['duration'] = duration;
      if (isActive != null) updateData['isActive'] = isActive;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;
      
      // Upload new image if provided
      if (imageBytes != null && imageName != null) {
        final imageUrl = await _cloudinaryService.uploadImage(imageBytes, imageName);
        if (imageUrl != null) {
          updateData['imageUrls'] = [imageUrl];
        }
      }
      
      if (updateData.isNotEmpty) {
        await _firestoreService.updateProduct(productId, updateData);
        AppConfig.log('Product updated successfully');
      }
      
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update product', e);
      _setError('Failed to update product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Deleting product: $productId');
      
      await _firestoreService.deleteProduct(productId);
      
      AppConfig.log('Product deleted successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to delete product', e);
      _setError('Failed to delete product');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product status (availability)
  Future<bool> updateProductStatus(String productId, bool isAvailable) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating product status: $productId to ${isAvailable ? "available" : "unavailable"}');
      
      await _firestoreService.updateProduct(productId, {'isAvailable': isAvailable});
      
      AppConfig.log('Product status updated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update product status', e);
      _setError('Failed to update product status');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      return await _firestoreService.getProduct(productId);
    } catch (e) {
      AppConfig.logError('Failed to get product', e);
      return null;
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _applyFilters();
    notifyListeners();
  }

  // Sort products
  void sortProducts(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applySorting();
    notifyListeners();
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => 
      product.category == category && product.isActive && product.isAvailable
    ).toList();
  }

  // Get featured products (highest rated or newest)
  List<ProductModel> getFeaturedProducts({int limit = 10}) {
    final featured = List<ProductModel>.from(_products);
    
    // Sort by rating first, then by creation date
    featured.sort((a, b) {
      if (a.rating != null && b.rating != null) {
        final ratingComparison = b.rating!.compareTo(a.rating!);
        if (ratingComparison != 0) return ratingComparison;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return featured
        .where((product) => product.isActive && product.isAvailable)
        .take(limit)
        .toList();
  }

  // Get popular products (most reviewed)
  List<ProductModel> getPopularProducts({int limit = 10}) {
    final popular = List<ProductModel>.from(_products);
    
    popular.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    
    return popular
        .where((product) => product.isActive && product.isAvailable)
        .take(limit)
        .toList();
  }

  // Get recent products
  List<ProductModel> getRecentProducts({int limit = 10}) {
    final recent = List<ProductModel>.from(_products);
    
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return recent
        .where((product) => product.isActive && product.isAvailable)
        .take(limit)
        .toList();
  }

  // Get products in price range
  List<ProductModel> getProductsInPriceRange(double minPrice, double maxPrice) {
    return _products.where((product) => 
      product.price >= minPrice && 
      product.price <= maxPrice &&
      product.isActive && 
      product.isAvailable
    ).toList();
  }

  // Get product statistics
  Map<String, dynamic> getProductStatistics() {
    final activeProducts = _products.where((p) => p.isActive).length;
    final availableProducts = _products.where((p) => p.isAvailable).length;
    final totalCategories = _categories.length;
    
    double averagePrice = 0;
    if (_products.isNotEmpty) {
      final totalPrice = _products.fold<double>(0, (sum, product) => sum + product.price);
      averagePrice = totalPrice / _products.length;
    }
    
    return {
      'total': _products.length,
      'active': activeProducts,
      'available': availableProducts,
      'categories': totalCategories,
      'averagePrice': averagePrice,
    };
  }

  // Apply filters and search
  void _applyFilters() {
    _filteredProducts = List<ProductModel>.from(_products);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) =>
        product.title.toLowerCase().contains(_searchQuery) ||
        product.description.toLowerCase().contains(_searchQuery) ||
        product.category.toLowerCase().contains(_searchQuery) ||
        product.tags.any((tag) => tag.toLowerCase().contains(_searchQuery))
      ).toList();
    }
    
    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) =>
        product.category == _selectedCategory
      ).toList();
    }
    
    // Apply sorting
    _applySorting();
  }

  // Apply sorting
  void _applySorting() {
    switch (_sortBy) {
      case 'title':
        _filteredProducts.sort((a, b) => _sortAscending 
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title));
        break;
      case 'price':
        _filteredProducts.sort((a, b) => _sortAscending 
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return _sortAscending 
            ? aRating.compareTo(bRating)
            : bRating.compareTo(aRating);
        });
        break;
      case 'createdAt':
      default:
        _filteredProducts.sort((a, b) => _sortAscending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // Update categories list
  void _updateCategories() {
    final categorySet = <String>{};
    for (final product in _products) {
      if (product.isActive) {
        categorySet.add(product.category);
      }
    }
    _categories = categorySet.toList()..sort();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    try {
      AppConfig.log('Refreshing products');
      // The stream will automatically update the products
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Failed to refresh products', e);
      _setError('Failed to refresh products');
    }
  }

  // Toggle product availability
  Future<bool> toggleProductAvailability(String productId, bool isAvailable) async {
    return await updateProduct(productId, isAvailable: isAvailable);
  }

  // Toggle product active status
  Future<bool> toggleProductActiveStatus(String productId, bool isActive) async {
    return await updateProduct(productId, isActive: isActive);
  }

  // Bulk update products
  Future<bool> bulkUpdateProducts(List<String> productIds, Map<String, dynamic> updateData) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Bulk updating ${productIds.length} products');
      
      for (final productId in productIds) {
        await _firestoreService.updateProduct(productId, updateData);
      }
      
      AppConfig.log('Bulk update completed successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to bulk update products', e);
      _setError('Failed to update products');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    AppConfig.log('Disposing ProductProvider');
    super.dispose();
  }
}
