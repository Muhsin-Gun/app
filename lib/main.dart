import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'core/theme.dart';
import 'core/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/message_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/marketplace_provider.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppConfig.log('Firebase initialized successfully');
    
    runApp(const ProMarketApp());
  } catch (e) {
    AppConfig.logError('Failed to initialize Firebase', e);
    runApp(const ErrorApp());
  }
}

class ProMarketApp extends StatelessWidget {
  const ProMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - Must be first as others depend on it
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Data Providers
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        
        // User-specific providers that will be initialized when user signs in
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                
                // Initial route based on auth state
                initialRoute: _getInitialRoute(authProvider),
                
                // Route generator
                onGenerateRoute: AppRouter.generateRoute,
                
                // Navigation observer for logging
                navigatorObservers: [
                  _NavigationObserver(),
                ],
                
                // Builder for global error handling
                builder: (context, widget) {
                  return _AppBuilder(
                    authProvider: authProvider,
                    child: widget ?? const SizedBox(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getInitialRoute(AuthProvider authProvider) {
    if (!authProvider.isInitialized) {
      return '/login'; // Show login while initializing
    }
    
    return AppRouter.getInitialRoute(
      isSignedIn: authProvider.isSignedIn,
      needsOnboarding: authProvider.needsOnboarding(),
      userRole: authProvider.userRole,
    );
  }
}

class _AppBuilder extends StatefulWidget {
  final AuthProvider authProvider;
  final Widget child;

  const _AppBuilder({
    required this.authProvider,
    required this.child,
  });

  @override
  State<_AppBuilder> createState() => _AppBuilderState();
}

class _AppBuilderState extends State<_AppBuilder> {
  @override
  void initState() {
    super.initState();
    _initializeUserSpecificProviders();
  }

  @override
  void didUpdateWidget(_AppBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if user changed
    if (oldWidget.authProvider.userId != widget.authProvider.userId) {
      _initializeUserSpecificProviders();
    }
  }

  void _initializeUserSpecificProviders() {
    if (widget.authProvider.isSignedIn && widget.authProvider.userId != null) {
      final userId = widget.authProvider.userId!;
      final userRole = widget.authProvider.userRole ?? 'client';
      
      AppConfig.log('Initializing user-specific providers for: $userId');
      
      // Initialize booking provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<BookingProvider>().initializeBookings(userId, userRole);
          context.read<MessageProvider>().initializeMessages(userId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppConfig.log('Navigation: Pushed ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppConfig.log('Navigation: Popped ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppConfig.log('Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

// Error app to show when Firebase initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProMarket - Error',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ErrorScreen(),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize the application. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Restart the app
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
