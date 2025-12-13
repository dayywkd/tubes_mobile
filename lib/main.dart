// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart';
import 'screens/payment_succes_screen.dart';

// Screens Auth (Pastikan file ini ada di folder screens/auth/ atau sesuaikan)
import 'screens/login_screen.dart'; 
import 'screens/register_screen.dart'; 
import 'screens/profile_screen.dart'; 

// --- GANTI DENGAN URL & KEY SUPABASE ANDA ---
const SUPABASE_URL = "https://bncbmzbgncxmlpqgsxqb.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuY2JtemJnbmN4bWxwcWdzeHFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNTU4NDksImV4cCI6MjA4MDkzMTg0OX0.iZ4EK-6z1Ss3FX305mZIRHNX-FyILISoNIbvhntNWxI";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
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

final supabase = Supabase.instance.client;

class TokoKopiSembilan extends StatelessWidget {
  const TokoKopiSembilan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Toko Kopi Sembilan",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // KITA MULAI DARI SPLASH SCREEN
      // Biarkan Splash Screen yang mengecek apakah user sudah login atau belum
      initialRoute: '/splash', 

      routes: {
        // Alur Awal
        '/splash': (context) => const SplashScreen(),
        '/onboard': (context) => const OnboardScreen(),
        
        // Auth
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Fitur Utama
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/order': (context) => const OrderScreen(),
        '/payment_success': (context) => const PaymentSuccessScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}