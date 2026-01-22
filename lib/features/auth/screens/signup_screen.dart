import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:promarket/providers/auth_provider.dart';
import 'package:promarket/features/auth/screens/login_screen.dart';
import 'package:promarket/core/constants.dart';
import 'package:promarket/routing/app_router.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/SignupScreen';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool obscureText = true;
  bool isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _repeatPasswordController;
  late final TextEditingController _phoneController;

  late final FocusNode _nameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _repeatPasswordFocusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _repeatPasswordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = image.name;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final cloudName = AppConstants.cloudinaryCloudName;
    final uploadPreset = AppConstants.cloudinaryUploadPreset;
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['secure_url'];
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile photo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (!success) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        return;
      }

      final imageUrl = await _uploadImageToCloudinary(
        _pickedImageBytes!,
        _pickedImageName ?? 'profile.jpg',
      );

      if (imageUrl != null) {
        await authProvider.updateUserProfile(
          phone: _phoneController.text.trim(),
          photoUrl: imageUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        AppRouter.navigateToDashboard(
          context,
          authProvider.userRole ?? 'client',
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 8),
                  Text(
                    'Join ProMarket today and experience premium services.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                                width: 4,
                              ),
                              image: _pickedImageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_pickedImageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _pickedImageBytes == null
                                ? Icon(
                                    IconlyLight.profile,
                                    size: 40,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.5),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildStyledField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          hint: 'Full Name',
                          icon: IconlyLight.profile,
                          validator: (v) =>
                              v!.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildStyledField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hint: 'Email Address',
                          icon: IconlyLight.message,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty || !v.contains('@')
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildStyledField(
                          controller: _phoneController,
                          hint: 'Phone Number',
                          icon: IconlyLight.call,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v!.isEmpty ? 'Phone number is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildStyledField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hint: 'Password',
                          icon: IconlyLight.lock,
                          obscureText: obscureText,
                          validator: (v) =>
                              v!.length < 6 ? 'Minimum 6 characters' : null,
                          suffix: IconButton(
                            icon: Icon(
                              obscureText ? IconlyLight.hide : IconlyLight.show,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStyledField(
                          controller: _repeatPasswordController,
                          focusNode: _repeatPasswordFocusNode,
                          hint: 'Confirm Password',
                          icon: IconlyLight.lock,
                          obscureText: true,
                          validator: (v) => v != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
      ),
    );
  }
}
