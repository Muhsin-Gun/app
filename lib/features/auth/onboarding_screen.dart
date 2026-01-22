import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      description: 'Book high-quality services from verified professionals',
      icon: 'person',
      color: Colors.blue,
    ),
    RoleOption(
      role: 'employee',
      title: 'Service Provider',
      description: 'Connect with clients and grow your service business',
      icon: 'engineering',
      color: Colors.green,
    ),
  ];

  Future<void> _completeOnboarding() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 6.h),

                  // App Icon/Illustration
                  Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'rocket_launch',
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(),

                  SizedBox(height: 4.h),

                  Text(
                    'Welcome to ProMarket',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 1.5.h),

                  Text(
                    'To provide you with the best experience, please tell us how you plan to use the app.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 6.h),

                  // Role selection cards
                  ...List.generate(_roleOptions.length, (index) {
                    final option = _roleOptions[index];
                    final isSelected = _selectedRole == option.role;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.5.h),
                      child:
                          GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedRole = option.role),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outlineVariant,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.15),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 14.w,
                                        height: 14.w,
                                        decoration: BoxDecoration(
                                          color:
                                              (isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                      : option.color)
                                                  .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Center(
                                          child: CustomIconWidget(
                                            iconName: option.icon,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : option.color,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option.title,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected
                                                        ? theme
                                                              .colorScheme
                                                              .onPrimaryContainer
                                                        : theme
                                                              .colorScheme
                                                              .onSurface,
                                                  ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              option.description,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? theme
                                                              .colorScheme
                                                              .onPrimaryContainer
                                                              .withOpacity(0.7)
                                                        : theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                          size: 24,
                                        ).animate().scale(duration: 200.ms),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (600 + (index * 100)).ms)
                              .slideX(begin: 0.1, end: 0),
                    );
                  }),

                  const Spacer(),

                  // Action Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedRole != null && !_isLoading
                          ? _completeOnboarding
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Get Started',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 1.seconds),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
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
