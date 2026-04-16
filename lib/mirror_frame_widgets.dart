import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'mirror_widgets.dart'; // এখানে AuraMirrorBorder উইজেটটি আছে নিশ্চিত করুন

class MirrorFrameView extends StatelessWidget {
  final bool isLightOn;
  final bool showHandIcon;
  final VoidCallback onTap;
  final Future<void>? initializeControllerFuture;

  // CameraController-কে Nullable করা হয়েছে যাতে শুরুতে রেড লাইন না আসে
  final CameraController? controller;
  final Widget gridLines;

  const MirrorFrameView({
    super.key,
    required this.isLightOn,
    required this.showHandIcon,
    required this.onTap,
    required this.initializeControllerFuture,
    this.controller, // এটি এখন অপশনাল, তাই লাল দাগ আসবে না
    required this.gridLines,
  });

  @override
  Widget build(BuildContext context) {
    return AuraMirrorBorder(
      isLightOn: isLightOn,
      activeColor: const Color(0xFFFFF4D2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.black, // ক্যামেরার পেছনে সলিড ব্ল্যাক
          width: double.infinity,
          height: double.infinity,
          child: FutureBuilder<void>(
            future: initializeControllerFuture,
            builder: (context, snapshot) {
              // ক্যামেরা রেডি হলে এবং কন্ট্রোলার নাল না হলে প্রিভিউ দেখাবে
              if (snapshot.connectionState == ConnectionState.done &&
                  controller != null) {
                return Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    // ১. মেইন ক্যামেরা প্রিভিউ
                    CameraPreview(controller!),

                    // ২. গ্রিড লাইনস
                    gridLines,

                    // ৩. ক্রিস্টাল ক্লিয়ার রিফ্লেকশন লেয়ার
                    _buildCrystalLayer(),

                    // ৪. হ্যান্ড আইকন অ্যানিমেশন
                    _buildHandIcon(),
                  ],
                );
              } else {
                // ক্যামেরা লোড হওয়ার সময় একটি সুন্দর লোডার
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white24,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // কাঁচের মতো স্বচ্ছ আভা তৈরি করার জন্য রিফ্লেকশন লেয়ার
  Widget _buildCrystalLayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.02),
            Colors.transparent,
            Colors.white.withOpacity(0.01),
          ],
        ),
      ),
    );
  }

  // ট্যাপ করলে হাতের আইকন দেখানোর লেয়ার
  Widget _buildHandIcon() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: showHandIcon ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.black12,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.touch_app_outlined,
          color: Colors.white70,
          size: 60,
        ),
      ),
    );
  }
}
