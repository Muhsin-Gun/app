import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Private variables
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  User? get user => _firebaseUser; // Added getter
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  UserModel? get currentUser => _userModel; // Added for compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isSignedIn => _firebaseUser != null;
  String? get userId => _firebaseUser?.uid;
  String? get userRole => _userModel?.role;
  String? get userName => _userModel?.name ?? _firebaseUser?.displayName;
  String? get userEmail => _userModel?.email ?? _firebaseUser?.email;
  String? get userPhotoUrl => _userModel?.photoUrl ?? _firebaseUser?.photoURL;

  // Role checks
  bool get isAdmin => _userModel?.isAdmin ?? false;
  bool get isClient => _userModel?.isClient ?? false;
  bool get isEmployee => _userModel?.isEmployee ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      AppConfig.log('Initializing AuthProvider');
      
      // Listen to Firebase Auth state changes
      _authService.authStateChanges.listen(_onAuthStateChanged);
      
      // Get current user if already signed in
      _firebaseUser = _authService.currentUser;
      if (_firebaseUser != null) {
        await _loadUserModel(_firebaseUser!.uid);
      }
      
      _isInitialized = true;
      notifyListeners();
      
      AppConfig.log('AuthProvider initialized successfully');
    } catch (e) {
      AppConfig.logError('Failed to initialize AuthProvider', e);
      _errorMessage = 'Failed to initialize authentication';
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Handle Firebase Auth state changes
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      AppConfig.log('Auth state changed: ${user?.email ?? 'null'}');
      
      _firebaseUser = user;
      
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      
      _clearError();
      notifyListeners();
    } catch (e) {
      AppConfig.logError('Error handling auth state change', e);
      _setError('Failed to load user data');
    }
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String uid) async {
    try {
      AppConfig.log('Loading user model for UID: $uid');
      
      final userModel = await _firestoreService.getUser(uid);
      if (userModel != null) {
        _userModel = userModel;
        AppConfig.log('User model loaded: ${userModel.email}, role: ${userModel.role}');
      } else {
        AppConfig.log('No user model found for UID: $uid');
        _userModel = null;
      }
    } catch (e) {
      AppConfig.logError('Failed to load user model', e);
      _userModel = null;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Starting Google sign-in');
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        AppConfig.log('Google sign-in successful');
        return true;
      } else {
        _setError('Google sign-in was cancelled');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Google sign-in failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with biometric authentication
  Future<bool> signInWithBiometric() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Starting biometric sign-in');
      
      // This would typically use local_auth package for biometric authentication
      // For now, we'll simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real implementation, you would:
      // 1. Check if biometric is available
      // 2. Authenticate with biometric
      // 3. Retrieve stored credentials
      // 4. Sign in with stored credentials
      
      // For demo purposes, return false (not implemented)
      _setError('Biometric authentication is not yet implemented');
      return false;
    } catch (e) {
      AppConfig.logError('Biometric sign-in failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Starting Apple sign-in');
      
      final userCredential = await _authService.signInWithApple();
      
      if (userCredential != null) {
        AppConfig.log('Apple sign-in successful');
        return true;
      } else {
        _setError('Apple sign-in was cancelled');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Apple sign-in failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Starting email/password sign-in');
      
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      
      if (userCredential != null) {
        AppConfig.log('Email/password sign-in successful');
        return true;
      } else {
        _setError('Sign-in failed');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Email/password sign-in failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create account with email and password
  Future<bool> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String name, {
    String role = 'client'
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Creating account with email/password');
      
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email, 
        password, 
        name, 
        role: role
      );
      
      if (userCredential != null) {
        AppConfig.log('Account created successfully');
        return true;
      } else {
        _setError('Account creation failed');
        return false;
      }
    } catch (e) {
      AppConfig.logError('Account creation failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Signing out user');
      
      await _authService.signOut();
      
      _firebaseUser = null;
      _userModel = null;
      
      AppConfig.log('Sign out successful');
      return true;
    } catch (e) {
      AppConfig.logError('Sign out failed', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_firebaseUser == null || _userModel == null) {
        _setError('No user signed in');
        return false;
      }
      
      AppConfig.log('Updating user profile');
      
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      
      if (updateData.isNotEmpty) {
        await _firestoreService.updateUser(_firebaseUser!.uid, updateData);
        
        // Reload user model
        await _loadUserModel(_firebaseUser!.uid);
        
        AppConfig.log('User profile updated successfully');
      }
      
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update user profile', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user role (admin only)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (!isAdmin) {
        _setError('Only admins can update user roles');
        return false;
      }
      
      AppConfig.log('Updating user role: $userId to $newRole');
      
      await _authService.updateUserRole(userId, newRole);
      
      AppConfig.log('User role updated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update user role', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Sending password reset email');
      
      await _authService.sendPasswordResetEmail(email);
      
      AppConfig.log('Password reset email sent successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to send password reset email', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating password');
      
      await _authService.updatePassword(newPassword);
      
      AppConfig.log('Password updated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update password', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Updating email');
      
      await _authService.updateEmail(newEmail);
      
      // Reload user model
      if (_firebaseUser != null) {
        await _loadUserModel(_firebaseUser!.uid);
      }
      
      AppConfig.log('Email updated successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to update email', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Deleting account');
      
      await _authService.deleteAccount();
      
      _firebaseUser = null;
      _userModel = null;
      
      AppConfig.log('Account deleted successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to delete account', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      
      AppConfig.log('Sending email verification');
      
      await _authService.sendEmailVerification();
      
      AppConfig.log('Email verification sent successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to send email verification', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      AppConfig.log('Reloading user data');
      
      await _authService.reloadUser();
      
      if (_firebaseUser != null) {
        await _loadUserModel(_firebaseUser!.uid);
      }
      
      notifyListeners();
      
      AppConfig.log('User data reloaded successfully');
    } catch (e) {
      AppConfig.logError('Failed to reload user data', e);
    }
  }

  // Check if user needs onboarding
  bool needsOnboarding() {
    return _firebaseUser != null && _userModel == null;
  }

  // Complete onboarding by setting user role
  Future<bool> completeOnboarding(String role) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_firebaseUser == null) {
        _setError('No user signed in');
        return false;
      }
      
      AppConfig.log('Completing onboarding with role: $role');
      
      final userModel = UserModel(
        uid: _firebaseUser!.uid,
        name: _firebaseUser!.displayName ?? 'User',
        email: _firebaseUser!.email ?? '',
        role: role,
        photoUrl: _firebaseUser!.photoURL,
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.createUser(userModel);
      _userModel = userModel;
      
      AppConfig.log('Onboarding completed successfully');
      return true;
    } catch (e) {
      AppConfig.logError('Failed to complete onboarding', e);
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get route based on user role
  String getInitialRoute() {
    if (!isSignedIn) {
      return '/login';
    }
    
    if (needsOnboarding()) {
      return '/onboarding';
    }
    
    switch (userRole) {
      case 'admin':
        return '/admin-dashboard';
      case 'client':
        return '/client-dashboard';
      case 'employee':
        return '/employee-dashboard';
      default:
        return '/login';
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

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'An account already exists with this email address';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled';
        case 'requires-recent-login':
          return 'Please sign in again to perform this action';
        default:
          return error.message ?? 'An authentication error occurred';
      }
    }
    
    return error.toString();
  }

  @override
  void dispose() {
    AppConfig.log('Disposing AuthProvider');
    super.dispose();
  }
}
