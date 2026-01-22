import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/auth_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';

class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({super.key});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'client';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<RoleOption> _roleOptions = [
    RoleOption(
      role: 'client',
      title: 'Client',
      description: 'Book services',
      icon: 'person',
      color: Colors.blue,
    ),
    RoleOption(
      role: 'employee',
      title: 'Employee',
      description: 'Provide services',
      icon: 'work',
      color: Colors.green,
    ),
    RoleOption(
      role: 'admin',
      title: 'Admin',
      description: 'Manage platform',
      icon: 'admin_panel_settings',
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (success && mounted) {
        // Navigate to appropriate dashboard based on role
        AppRouter.navigateToDashboard(context, _selectedRole);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                SizedBox(height: 2.h),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter email';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                SizedBox(height: 2.h),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 2.h),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 3.h),

                // Role Selection
                Text(
                  'Select Your Role',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),

                ..._roleOptions.map((option) {
                  final isSelected = _selectedRole == option.role;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: InkWell(
                      onTap: () => setState(() => _selectedRole = option.role),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: option.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                option.icon == 'person' ? Icons.person : 
                                option.icon == 'work' ? Icons.work : Icons.admin_panel_settings,
                                color: option.color,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    option.description,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                SizedBox(height: 4.h),

                // Register Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),

                SizedBox(height: 2.h),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleOption {
  final String role;
  final String title;
  final String description;
  final String icon;
  final Color color;

  RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
