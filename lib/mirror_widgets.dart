import 'package:flutter/material.dart';

// --- মিরর ফ্রেমের কাস্টম বর্ডার এবং লাইট ইফেক্ট উইজেট ---
class AuraMirrorBorder extends StatelessWidget {
  final bool isLightOn;
  final Widget child;
  final Color activeColor;

  const AuraMirrorBorder({
    super.key,
    required this.isLightOn,
    required this.child,
    this.activeColor = Colors.white, // ডিফল্ট সাদা, লজিক অনুযায়ী চেঞ্জ হবে
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // লাইট অফ থাকলে সাদা বর্ডার (opacity 0.2), অন থাকলে activeColor
        border: Border.all(
          color: isLightOn ? activeColor : Colors.white.withOpacity(0.5),
          width: isLightOn ? 7.0 : 4.5,
        ),
        boxShadow: [
          if (isLightOn)
            BoxShadow(
              color: activeColor.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          // ডার্ক ডেপথ শ্যাডো (সবসময় থাকবে)
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: child),
    );
  }
}

// --- মিরর ফ্রেমের ভেতরের গ্রিড লাইন পেইন্টার ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.06) // খুবই হালকা সাদা লাইন
      ..strokeWidth = 0.5;

    // Vertical Lines (উলম্ব রেখা)
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Horizontal Lines (অনুভূমিক রেখা)
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
