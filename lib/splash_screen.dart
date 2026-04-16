import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'mirror_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ১. নেটিভ সাদা স্ক্রিনটি সরিয়ে ফেলবে যখন ফ্ল্যাটার রেন্ডার করা শুরু করবে
    FlutterNativeSplash.remove();

    // ২. এনিমেশন সেটআপ
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // ৩. ৩ সেকেন্ড পর মিরর স্ক্রিনে চলে যাবে
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MirrorScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // আরও প্রফেশনাল ট্রানজিশন (Fade)
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // আপনার অ্যাপের ব্যাকগ্রাউন্ড কালার
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // আপনার অ্যাপের লোগো বা আইকন
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,// এখানে আপনার পছন্দের আইকন বা Image.asset দিতে পারেন
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              // অ্যাপের নাম
              const Text(
                "SMART MIRROR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Reflect Your Style",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}