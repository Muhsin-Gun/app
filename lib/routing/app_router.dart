import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/role_selector_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/client/client_dashboard_screen.dart';
import '../features/employee/employee_dashboard_screen.dart';
import '../features/profile/screens/provider_profile_screen.dart';
import '../features/chat/screens/chat_screen.dart';

class AppRouter {
  static const String loginRoute = '/LoginScreen';
  static const String signupRoute = '/SignupScreen';
  static const String onboardingRoute = '/onboarding';
  static const String roleSelectorRoute = '/role-selector';
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String clientDashboardRoute = '/client-dashboard';
  static const String employeeDashboardRoute = '/employee-dashboard';
  static const String chatRoute = '/chat';

  // Generate route based on settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    AppConfig.log('Navigating to: ${settings.name}');
    
    switch (settings.name) {
      case '/':
      case loginRoute:
        return _buildRoute(const LoginScreen(), settings);

      case signupRoute:
        return _buildRoute(const SignupScreen(), settings);
        
      case onboardingRoute:
        return _buildRoute(const OnboardingScreen(), settings);
        
      case roleSelectorRoute:
        return _buildRoute(const RoleSelectorScreen(), settings);
        
      case adminDashboardRoute:
        return _buildRoute(const AdminDashboardScreen(), settings);
        
      case clientDashboardRoute:
        return _buildRoute(const ClientDashboardScreen(), settings);
        
      case employeeDashboardRoute:
        return _buildRoute(const EmployeeDashboardScreen(), settings);

      case '/provider-profile':
        final args = settings.arguments as String;
        return _buildRoute(ProviderProfileScreen(providerId: args), settings);

      case chatRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          ChatScreen(
            otherUserId: args['otherUserId'],
            otherUserName: args['otherUserName'],
          ),
          settings,
        );
        
      default:
        AppConfig.logError('Unknown route: ${settings.name}');
        return _buildRoute(_buildUnknownRoute(), settings);
    }
  }

  // Build route with transition animation
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right to left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Build unknown route page
  static Widget _buildUnknownRoute() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get initial route based on user authentication state
  static String getInitialRoute({
    required bool isSignedIn,
    required bool needsOnboarding,
    String? userRole,
  }) {
    if (!isSignedIn) {
      return loginRoute;
    }
    
    if (needsOnboarding) {
      return onboardingRoute;
    }
    
    switch (userRole) {
      case 'admin':
        return adminDashboardRoute;
      case 'client':
        return clientDashboardRoute;
      case 'employee':
        return employeeDashboardRoute;
      default:
        return loginRoute;
    }
  }

  // Navigate to dashboard based on user role
  static void navigateToDashboard(BuildContext context, String userRole) {
    String route;
    
    switch (userRole) {
      case 'admin':
        route = adminDashboardRoute;
        break;
      case 'client':
        route = clientDashboardRoute;
        break;
      case 'employee':
        route = employeeDashboardRoute;
        break;
      default:
        route = loginRoute;
    }
    
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (Route<dynamic> route) => false,
    );
  }

  // Navigate to login and clear stack
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (Route<dynamic> route) => false,
    );
  }

  // Navigate to onboarding
  static void navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      onboardingRoute,
      (Route<dynamic> route) => false,
    );
  }

  // Check if route requires authentication
  static bool requiresAuthentication(String? routeName) {
    const publicRoutes = [
      loginRoute,
      onboardingRoute,
      roleSelectorRoute,
    ];
    
    return !publicRoutes.contains(routeName);
  }

  // Check if route is dashboard route
  static bool isDashboardRoute(String? routeName) {
    const dashboardRoutes = [
      adminDashboardRoute,
      clientDashboardRoute,
      employeeDashboardRoute,
    ];
    
    return dashboardRoutes.contains(routeName);
  }

  // Get route name for user role
  static String getRouteForRole(String role) {
    switch (role) {
      case 'admin':
        return adminDashboardRoute;
      case 'client':
        return clientDashboardRoute;
      case 'employee':
        return employeeDashboardRoute;
      default:
        return loginRoute;
    }
  }

  // Check if user can access route
  static bool canAccessRoute(String? routeName, String? userRole) {
    if (routeName == null) return false;
    
    // Public routes can be accessed by anyone
    if (!requiresAuthentication(routeName)) {
      return true;
    }
    
    // Dashboard routes require specific roles
    switch (routeName) {
      case adminDashboardRoute:
        return userRole == 'admin';
      case clientDashboardRoute:
        return userRole == 'client';
      case employeeDashboardRoute:
        return userRole == 'employee';
      default:
        return false;
    }
  }

  // Navigate with role check
  static void navigateWithRoleCheck(
    BuildContext context,
    String routeName,
    String? userRole,
  ) {
    if (canAccessRoute(routeName, userRole)) {
      Navigator.of(context).pushNamed(routeName);
    } else {
      AppConfig.logError('Access denied to route: $routeName for role: $userRole');
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Access Denied'),
          content: const Text('You do not have permission to access this page.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Replace current route
  static void replaceRoute(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  // Push route and clear stack
  static void pushAndClearStack(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
    );
  }

  // Go back or navigate to fallback route
  static void goBackOrFallback(BuildContext context, String fallbackRoute) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(fallbackRoute);
    }
  }

  // Custom transition for specific routes
  static Route<dynamic> buildCustomRoute(
    Widget page,
    RouteSettings settings, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Build slide up transition (for modals)
  static Route<dynamic> buildSlideUpRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
