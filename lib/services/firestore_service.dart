import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_config.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/booking_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      AppConfig.log('Creating user: ${user.email}');
      await _db.collection(AppConstants.usersCollection).doc(user.uid).set(user.toMap());
      AppConfig.log('User created successfully');
    } catch (e) {
      AppConfig.logError('Failed to create user', e);
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      AppConfig.logError('Failed to get user', e);
      return null;
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection(AppConstants.usersCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    });
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      AppConfig.log('Updating user: $uid');
      data['updatedAt'] = Timestamp.now();
      await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
      AppConfig.log('User updated successfully');
    } catch (e) {
      AppConfig.logError('Failed to update user', e);
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      AppConfig.log('Deleting user: $uid');
      await _db.collection(AppConstants.usersCollection).doc(uid).delete();
      AppConfig.log('User deleted successfully');
    } catch (e) {
      AppConfig.logError('Failed to delete user', e);
      rethrow;
    }
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList());
  }

  // Get all users (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList());
  }

  // ==================== PRODUCT OPERATIONS ====================

  // Create product
  Future<String> createProduct(ProductModel product) async {
    try {
      AppConfig.log('Creating product: ${product.title}');
      final docRef = await _db.collection(AppConstants.productsCollection).add(product.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      AppConfig.log('Product created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppConfig.logError('Failed to create product', e);
      rethrow;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _db.collection(AppConstants.productsCollection).doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      AppConfig.logError('Failed to get product', e);
      return null;
    }
  }

  // Get all products stream
  Stream<List<ProductModel>> getProductsStream() {
    return _db
        .collection(AppConstants.productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _db
        .collection(AppConstants.productsCollection)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      AppConfig.log('Searching products with query: $query');
      
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that searches by title
      final snapshot = await _db
          .collection(AppConstants.productsCollection)
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .get();
      
      final products = snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList();
      
      // Filter products that match the search query
      final filteredProducts = products.where((product) => product.matchesSearch(query)).toList();
      
      AppConfig.log('Found ${filteredProducts.length} products matching query');
      return filteredProducts;
    } catch (e) {
      AppConfig.logError('Failed to search products', e);
      return [];
    }
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      AppConfig.log('Updating product: $productId');
      data['updatedAt'] = Timestamp.now();
      await _db.collection(AppConstants.productsCollection).doc(productId).update(data);
      AppConfig.log('Product updated successfully');
    } catch (e) {
      AppConfig.logError('Failed to update product', e);
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      AppConfig.log('Deleting product: $productId');
      await _db.collection(AppConstants.productsCollection).doc(productId).delete();
      AppConfig.log('Product deleted successfully');
    } catch (e) {
      AppConfig.logError('Failed to delete product', e);
      rethrow;
    }
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    try {
      final snapshot = await _db
          .collection(AppConstants.productsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final categories = <String>{};
      for (final doc in snapshot.docs) {
        final product = ProductModel.fromDocument(doc);
        categories.add(product.category);
      }
      
      return categories.toList()..sort();
    } catch (e) {
      AppConfig.logError('Failed to get product categories', e);
      return [];
    }
  }

  // ==================== BOOKING OPERATIONS ====================

  // Create booking
  Future<String> createBooking(BookingModel booking) async {
    try {
      AppConfig.log('Creating booking for product: ${booking.productId}');
      final docRef = await _db.collection(AppConstants.bookingsCollection).add(booking.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      AppConfig.log('Booking created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppConfig.logError('Failed to create booking', e);
      rethrow;
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      final doc = await _db.collection(AppConstants.bookingsCollection).doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      AppConfig.logError('Failed to get booking', e);
      return null;
    }
  }

  // Get bookings for user
  Stream<List<BookingModel>> getBookingsForUser(String userId, String role) {
    Query query = _db.collection(AppConstants.bookingsCollection);
    
    switch (role) {
      case 'client':
        query = query.where('clientId', isEqualTo: userId);
        break;
      case 'employee':
        query = query.where('employeeId', isEqualTo: userId);
        break;
      case 'admin':
        // Admin sees all bookings
        break;
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList());
  }

  // Get bookings by status
  Stream<List<BookingModel>> getBookingsByStatus(String status) {
    return _db
        .collection(AppConstants.bookingsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BookingModel.fromDocument(doc)).toList());
  }

  // Update booking
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    try {
      AppConfig.log('Updating booking: $bookingId');
      data['updatedAt'] = Timestamp.now();
      await _db.collection(AppConstants.bookingsCollection).doc(bookingId).update(data);
      AppConfig.log('Booking updated successfully');
    } catch (e) {
      AppConfig.logError('Failed to update booking', e);
      rethrow;
    }
  }

  // Assign booking to employee
  Future<void> assignBookingToEmployee(String bookingId, String employeeId) async {
    try {
      AppConfig.log('Assigning booking $bookingId to employee $employeeId');
      await updateBooking(bookingId, {
        'employeeId': employeeId,
        'status': AppConstants.assignedStatus,
      });
      AppConfig.log('Booking assigned successfully');
    } catch (e) {
      AppConfig.logError('Failed to assign booking', e);
      rethrow;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      AppConfig.log('Updating booking $bookingId status to $newStatus');
      await updateBooking(bookingId, {
        'status': newStatus,
      });
      AppConfig.log('Booking status updated successfully');
    } catch (e) {
      AppConfig.logError('Failed to update booking status', e);
      rethrow;
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  // Send message
  Future<String> sendMessage(MessageModel message) async {
    try {
      AppConfig.log('Sending message from ${message.senderId} to ${message.receiverId}');
      final docRef = await _db.collection(AppConstants.messagesCollection).add(message.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      AppConfig.log('Message sent successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppConfig.logError('Failed to send message', e);
      rethrow;
    }
  }

  // Get messages for conversation
  Stream<List<MessageModel>> getMessagesForConversation(String userId1, String userId2, {String? bookingId}) {
    Query query = _db.collection(AppConstants.messagesCollection);
    
    if (bookingId != null) {
      // Get messages for specific booking
      query = query.where('bookingId', isEqualTo: bookingId);
    } else {
      // Get messages between two users
      query = query.where('senderId', whereIn: [userId1, userId2]);
    }
    
    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs.map((doc) => MessageModel.fromDocument(doc)).toList();
          
          if (bookingId == null) {
            // Filter messages between the two users
            return messages.where((message) =>
                (message.senderId == userId1 && message.receiverId == userId2) ||
                (message.senderId == userId2 && message.receiverId == userId1)
            ).toList();
          }
          
          return messages;
        });
  }

  // Get conversations for user
  Stream<List<MessageModel>> getConversationsForUser(String userId) {
    return _db
        .collection(AppConstants.messagesCollection)
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromDocument(doc)).toList());
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _db.collection(AppConstants.messagesCollection).doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      AppConfig.logError('Failed to mark message as read', e);
      rethrow;
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final snapshot = await _db
          .collection(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      AppConfig.logError('Failed to get unread message count', e);
      return 0;
    }
  }

  // ==================== ANALYTICS OPERATIONS ====================

  // Get booking statistics
  Future<Map<String, int>> getBookingStatistics() async {
    try {
      final snapshot = await _db.collection(AppConstants.bookingsCollection).get();
      
      final stats = <String, int>{
        'total': 0,
        'pending': 0,
        'assigned': 0,
        'active': 0,
        'completed': 0,
        'cancelled': 0,
      };
      
      for (final doc in snapshot.docs) {
        final booking = BookingModel.fromDocument(doc);
        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[booking.status] = (stats[booking.status] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      AppConfig.logError('Failed to get booking statistics', e);
      return {};
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final snapshot = await _db.collection(AppConstants.usersCollection).get();
      
      final stats = <String, int>{
        'total': 0,
        'admin': 0,
        'client': 0,
        'employee': 0,
        'active': 0,
      };
      
      for (final doc in snapshot.docs) {
        final user = UserModel.fromDocument(doc);
        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[user.role] = (stats[user.role] ?? 0) + 1;
        if (user.isActive) {
          stats['active'] = (stats['active'] ?? 0) + 1;
        }
      }
      
      return stats;
    } catch (e) {
      AppConfig.logError('Failed to get user statistics', e);
      return {};
    }
  }

  // ==================== BATCH OPERATIONS ====================

  // Batch update multiple documents
  Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _db.batch();
      
      for (final update in updates) {
        final collection = update['collection'] as String;
        final docId = update['docId'] as String;
        final data = update['data'] as Map<String, dynamic>;
        
        final docRef = _db.collection(collection).doc(docId);
        batch.update(docRef, data);
      }
      
      await batch.commit();
      AppConfig.log('Batch update completed successfully');
    } catch (e) {
      AppConfig.logError('Failed to perform batch update', e);
      rethrow;
    }
  }

  // Batch delete multiple documents
  Future<void> batchDelete(List<Map<String, String>> deletes) async {
    try {
      final batch = _db.batch();
      
      for (final delete in deletes) {
        final collection = delete['collection']!;
        final docId = delete['docId']!;
        
        final docRef = _db.collection(collection).doc(docId);
        batch.delete(docRef);
      }
      
      await batch.commit();
      AppConfig.log('Batch delete completed successfully');
    } catch (e) {
      AppConfig.logError('Failed to perform batch delete', e);
      rethrow;
    }
  }
}