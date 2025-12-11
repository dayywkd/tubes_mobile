import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'onboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController fadeCtrl;
  late AnimationController scaleCtrl;
  late AnimationController slideCtrl;

  late Animation<double> fadeAnim;
  late Animation<double> scaleAnim;
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();

    // FADE-IN ANIMATION
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: fadeCtrl, curve: Curves.easeInOut),
    );

    // SCALE ANIMATION (ZOOM)
    scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: scaleCtrl, curve: Curves.easeOutBack),
    );

    // SLIDE-UP TEXT ANIMATION
    slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: slideCtrl, curve: Curves.easeOut));

    // Jalankan animasi berurutan
    fadeCtrl.forward();
    scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () => slideCtrl.forward());

    // Auto-pindah ke OnboardScreen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardScreen()),
      );
    });
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    scaleCtrl.dispose();
    slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO WITH SHIMMER GLOW
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.8),
                        AppTheme.primary.withOpacity(0.45),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.local_cafe,
                    color: Colors.white,
                    size: 70,
                  ),
                ),

                const SizedBox(height: 18),

                SlideTransition(
                  position: slideAnim,
                  child: const Text(
                    "Toko Kopi Sembilan",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                SlideTransition(
                  position: slideAnim,
                  child: Text(
                    "Premium Coffee Experience",
                    style: TextStyle(
                      color: Colors.brown.shade400,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
