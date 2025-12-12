// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart'; // Import OrderScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bncmbzbgncxmlpqgsxqb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuY2JtemJnbmN4bWxwcWdzeHFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNTU4NDksImV4cCI6MjA4MDkzMTg0OX0.iZ4EK-6z1Ss3FX305mZIRHNX-FyILISoNIbvhntNWxI',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const TokoKopiSembilan(),
    ),
  );
}

class TokoKopiSembilan extends StatelessWidget {
  const TokoKopiSembilan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Toko Kopi Sembilan",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ==========================
      //        ROUTE SYSTEM
      // ==========================
      routes: {
        "/home": (_) => const HomeScreen(),
        "/cart": (_) => const CartScreen(),
        "/order": (_) =>
            const OrderScreen(), // Rute baru untuk konfirmasi order
      },

      // FIRST SCREEN on app launch
      home: const SplashScreen(),
    );
  }
}
