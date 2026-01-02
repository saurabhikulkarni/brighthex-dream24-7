import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:shop/screens/splash/splash_screen.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/search_service.dart';
import 'package:shop/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive for GraphQL caching
    await initHiveForFlutter();
    
    // Initialize User Service (loads userId from SharedPreferences)
    await UserService.initialize();
    
    // Initialize Auth Service for session persistence
    await authService.initialize();
    
    // Initialize Wishlist Service
    await wishlistService.initialize();
    
    // Sync wishlist with backend if user is logged in
    if (await authService.isLoggedIn()) {
      await wishlistService.syncWithBackend();
    }
    
    // Initialize Cart Service
    await cartService.initialize();
    
    // Sync cart with backend if user is logged in
    if (await authService.isLoggedIn()) {
      await cartService.syncWithBackend();
    }
    
    // Initialize Search Service
    await searchService.initialize();
  } catch (e) {
    // Log initialization errors but don't crash the app
    debugPrint('⚠️ Initialization error: $e');
    // Continue with app launch even if some services fail
  }
  
  runApp(const MyApp());
}

// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DREAM 247 - Shopping App',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      home: const SplashScreen(),
    );
  }
}
