import 'package:flutter/material.dart';

// --- ক্লিন অ্যান্ড ব্রাইট সলিড বর্ডার উইজেট (টোটাল শ্যাডো ফ্রি) ---
class AuraMirrorBorder extends StatelessWidget {
  final bool isLightOn;
  final Widget child;
  final Color activeColor;

  const AuraMirrorBorder({
    super.key,
    required this.isLightOn,
    required this.child,
    this.activeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // কোনো boxShadow নেই, তাই আইকন থাকবে একদম ক্লিয়ার
        border: Border.all(
          // লাইট অন হলে সলিড কড়া সাদা, অফ থাকলে হালকা সাদা
          color: isLightOn ? Colors.white : Colors.white.withOpacity(0.3),

          // লাইট অন হলে বর্ডার উইডথ ১০.০ করা হয়েছে যাতে আলো বেশি আসে
          // আপনার যদি এটি বেশি চওড়া মনে হয়, তবে স্রেফ ৭.৫ বা ৮.০ করে দেবেন
          width: isLightOn ? 3.0 : 3.0,
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: child),
    );
  }
}

// --- মিরর গ্রিড লাইন পেইন্টার ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;

    // Vertical Lines
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

    // Horizontal Lines
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
