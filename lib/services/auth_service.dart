import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../core/app_config.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: AppConfig.googleWebClientId,
  );
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      AppConfig.log('Starting Google Sign-In process');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        AppConfig.log('Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      AppConfig.log('Google Sign-In successful for user: ${userCredential.user?.email}');
      
      // Check if user exists in Firestore, if not create user document
      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      AppConfig.logError('Google Sign-In failed', e);
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      AppConfig.log('Starting Apple Sign-In process');
      
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      
      AppConfig.log('Apple Sign-In successful for user: ${userCredential.user?.email}');
      
      // Check if user exists in Firestore, if not create user document
      if (userCredential.user != null) {
        await _handleUserSignIn(userCredential.user!, appleCredential: appleCredential);
      }
      
      return userCredential;
    } catch (e) {
      AppConfig.logError('Apple Sign-In failed', e);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      AppConfig.log('Starting email/password sign-in for: $email');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      AppConfig.log('Email/password sign-in successful for user: ${userCredential.user?.email}');
      
      return userCredential;
    } catch (e) {
      AppConfig.logError('Email/password sign-in failed', e);
      rethrow;
    }
  }

  // Create account with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String name,
    {String role = 'client'}
  ) async {
    try {
      AppConfig.log('Creating account for: $email');
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        
        // Create user document in Firestore
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email.trim(),
          role: role,
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        
        await _firestoreService.createUser(userModel);
        
        AppConfig.log('Account created successfully for user: ${userCredential.user?.email}');
      }
      
      return userCredential;
    } catch (e) {
      AppConfig.logError('Account creation failed', e);
      rethrow;
    }
  }

  // Handle user sign-in (create user document if doesn't exist)
  Future<void> _handleUserSignIn(User user, {AuthorizationCredentialAppleID? appleCredential}) async {
    try {
      // Check if user document exists
      final existingUser = await _firestoreService.getUser(user.uid);
      
      if (existingUser == null) {
        // Create new user document
        String displayName = user.displayName ?? '';
        
        // For Apple Sign-In, construct name from Apple credential
        if (appleCredential != null && displayName.isEmpty) {
          final givenName = appleCredential.givenName ?? '';
          final familyName = appleCredential.familyName ?? '';
          displayName = '$givenName $familyName'.trim();
        }
        
        // Fallback to email if no name available
        if (displayName.isEmpty) {
          displayName = user.email?.split('@').first ?? 'User';
        }
        
        final userModel = UserModel(
          uid: user.uid,
          name: displayName,
          email: user.email ?? '',
          role: 'client', // Default role for new users
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        
        await _firestoreService.createUser(userModel);
        AppConfig.log('Created new user document for: ${user.email}');
      } else {
        // Update last login time
        await _firestoreService.updateUser(user.uid, {
          'updatedAt': DateTime.now(),
        });
        AppConfig.log('Updated existing user document for: ${user.email}');
      }
    } catch (e) {
      AppConfig.logError('Failed to handle user sign-in', e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      AppConfig.log('Signing out user');
      
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Firebase
      await _auth.signOut();
      
      AppConfig.log('User signed out successfully');
    } catch (e) {
      AppConfig.logError('Sign out failed', e);
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      
      AppConfig.log('Deleting account for user: ${user.email}');
      
      // Delete user document from Firestore
      await _firestoreService.deleteUser(user.uid);
      
      // Delete Firebase Auth account
      await user.delete();
      
      AppConfig.log('Account deleted successfully');
    } catch (e) {
      AppConfig.logError('Account deletion failed', e);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppConfig.log('Sending password reset email to: $email');
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      
      AppConfig.log('Password reset email sent successfully');
    } catch (e) {
      AppConfig.logError('Failed to send password reset email', e);
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      
      AppConfig.log('Updating password for user: ${user.email}');
      
      await user.updatePassword(newPassword);
      
      AppConfig.log('Password updated successfully');
    } catch (e) {
      AppConfig.logError('Password update failed', e);
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      
      AppConfig.log('Updating email for user: ${user.email} to: $newEmail');
      
      await user.updateEmail(newEmail.trim());
      
      // Update email in Firestore as well
      await _firestoreService.updateUser(user.uid, {
        'email': newEmail.trim(),
        'updatedAt': DateTime.now(),
      });
      
      AppConfig.log('Email updated successfully');
    } catch (e) {
      AppConfig.logError('Email update failed', e);
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');
      
      if (!user.emailVerified) {
        AppConfig.log('Sending email verification to: ${user.email}');
        await user.sendEmailVerification();
        AppConfig.log('Email verification sent successfully');
      }
    } catch (e) {
      AppConfig.logError('Failed to send email verification', e);
      rethrow;
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        AppConfig.log('User data reloaded');
      }
    } catch (e) {
      AppConfig.logError('Failed to reload user data', e);
      rethrow;
    }
  }

  // Get user role from Firestore
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final userModel = await _firestoreService.getUser(user.uid);
      return userModel?.role;
    } catch (e) {
      AppConfig.logError('Failed to get user role', e);
      return null;
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      AppConfig.log('Updating user role for $userId to $newRole');
      
      await _firestoreService.updateUser(userId, {
        'role': newRole,
        'updatedAt': DateTime.now(),
      });
      
      AppConfig.log('User role updated successfully');
    } catch (e) {
      AppConfig.logError('Failed to update user role', e);
      rethrow;
    }
  }
}
