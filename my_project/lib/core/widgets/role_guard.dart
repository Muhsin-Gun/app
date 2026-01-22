import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_router.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final String allowedRole;
  final String fallbackRoute;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRole,
    this.fallbackRoute = AppRouter.loginRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isSignedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
          });
          return const SizedBox();
        }

        if (authProvider.userRole != allowedRole) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(fallbackRoute);
          });
          return const SizedBox();
        }

        return child;
      },
    );
  }
}
