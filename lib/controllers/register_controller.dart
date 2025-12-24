import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  RegisterController({
    required this.context,
    required this.emailController,
    required this.passwordController,
  });

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> signUp(Function(bool) setLoading) async {
    setLoading(true);

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!context.mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pendaftaran Berhasil! Silakan cek email dan login.',
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Gagal. Coba lagi.')),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran Gagal: ${e.message}')),
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
