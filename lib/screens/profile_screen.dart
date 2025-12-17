// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/theme.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final supabase = Supabase.instance.client;
    try {
      // 1. Lakukan Logout di Supabase
      await supabase.auth.signOut();

      if (context.mounted) {
        // 2. NAVIGASI PAKSA KE HALAMAN LOGIN
        // pushNamedAndRemoveUntil menghapus semua history halaman (tidak bisa di-back)
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout Berhasil!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan tak terduga.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    // Mendapatkan data pengguna saat ini
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'Tidak Ditemukan';
    final userId = user?.id ?? 'Tidak Ditemukan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Menampilkan Email
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.email, color: AppTheme.primary),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
              ),
              // Menampilkan User ID
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.vpn_key, color: AppTheme.primary),
                  title: const Text('User ID (Supabase)'),
                  subtitle: Text(userId),
                ),
              ),
              const Spacer(), // Dorong tombol ke bawah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
