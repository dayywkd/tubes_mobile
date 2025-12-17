// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Tunggu 2 detik agar logo terlihat
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cek apakah ada user yang sedang login di Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // JIKA SUDAH LOGIN -> Ke Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // JIKA BELUM LOGIN -> Ke Onboard
      Navigator.pushReplacementNamed(context, '/onboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan warna cream muda seperti desain lainnya
      backgroundColor: const Color(0xFFF5F2EE), // Ganti warna jika perlu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pastikan Anda punya gambar ini di assets, atau ganti dengan Icon/Text
            Image.asset('assets/kopi.png', width: 120), 
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}