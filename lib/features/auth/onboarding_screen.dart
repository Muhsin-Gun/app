import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_router.dart';
import '../../widgets/custom_icon_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<RoleOption> _roleOptions = [
    RoleOption(
      role: 'client',
      title: 'Client',
      description: 'Book services from professional providers',
      icon: 'person',
      color: Colors.blue,
    ),
    RoleOption(
      role: 'employee',
      title: 'Service Provider',
      description: 'Offer your services to clients',
      icon: 'work',
      color: Colors.green,
    ),
  ];

  Future<void> _completeOnboarding() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.completeOnboarding(_selectedRole!);

      if (success && mounted) {
        AppRouter.navigateToDashboard(context, _selectedRole!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),

              // Welcome Header
              Text(
                'Welcome to ProMarket!',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              Text(
                'Choose your role to get started',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              // Role Selection
              Expanded(
                child: ListView.separated(
                  itemCount: _roleOptions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 3.h),
                  itemBuilder: (context, index) {
                    final option = _roleOptions[index];
                    final isSelected = _selectedRole == option.role;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRole = option.role;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 15.w,
                              height: 15.w,
                              decoration: BoxDecoration(
                                color: option.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: option.icon,
                                  color: option.color,
                                  size: 8.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    option.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: theme.colorScheme.primary,
                                size: 6.w,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 4.h),

              // Continue Button
              SizedBox(
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _selectedRole != null && !_isLoading
                      ? _completeOnboarding
                      : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),

              SizedBox(height: 2.h),
            ],
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