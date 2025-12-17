import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

// Pastikan file ini ada (hasil dari flutterfire configure)
// Jika error merah, jalankan: flutterfire configure di terminal
import 'firebase_options.dart';

import 'config/theme.dart';
import 'controllers/notification_controller.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart';
import 'screens/payment_succes_screen.dart'; // Perhatikan ejaan sesuai file kamu (satu 's')
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_screen.dart';

const SUPABASE_URL = "https://bncbmzbgncxmlpqgsxqb.supabase.co";
const SUPABASE_ANON_KEY =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuY2JtemJnbmN4bWxwcWdzeHFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNTU4NDksImV4cCI6MjA4MDkzMTg0OX0.iZ4EK-6z1Ss3FX305mZIRHNX-FyILISoNIbvhntNWxI";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ERROR HANDLING: Cek apakah firebase_options.dart sudah terdeteksi
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Jika gagal pakai options (misal file belum generate), coba inisialisasi biasa
    // Ini backup plan agar aplikasi tidak langsung crash
    print(
        "Warning: DefaultFirebaseOptions not found or failed. Trying default init. Error: $e");
    await Firebase.initializeApp();
  }

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  // Inject Controller (Wajib untuk Modul 6)
  Get.put(NotificationController());

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
    return GetMaterialApp(
      title: "Toko Kopi Sembilan",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: '/splash',

      // Saya hapus 'const' di sini untuk mencegah error jika Screen kamu belum const
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboard', page: () => const OnboardScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/cart', page: () => const CartScreen()),
        GetPage(name: '/notification', page: () => const NotificationScreen()),

        // Pastikan OrderScreen ada di folder screens/order_screen.dart
        GetPage(name: '/order', page: () => const OrderScreen()),

        // Perhatikan ejaan nama file kamu: payment_succes_screen.dart (satu 's')
        GetPage(
            name: '/payment_success', page: () => const PaymentSuccessScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
      ],
    );
  }
}
