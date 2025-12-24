import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginController({
    required this.context,
    required this.emailController,
    required this.passwordController,
  });

  final supabase = Supabase.instance.client;

  Future<void> signIn(Function(bool) setLoading) async {
    setLoading(true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!context.mounted) return;

      if (response.user != null) {
        Navigator.pushReplacementNamed(context, '/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil!')),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${e.message}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan tak terduga.')),
        );
      }
    } finally {
      if (context.mounted) setLoading(false);
    }
  }
}
