import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'mirror_logic.dart';

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});
  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  final MirrorLogic _logic = MirrorLogic();
  double _zoomLevel = 1.0;
  bool _isLightOn = false;

  @override
  void initState() {
    super.initState();
    _logic.initCamera().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_logic.controller == null || !_logic.controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ১. মেইন ক্যামেরা প্রিভিউ (Mirror Flip)
          Positioned.fill(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: CameraPreview(_logic.controller!),
            ),
          ),

          // ২. গ্রিড লাইন (ইমেজের মতো পাতলা ৩x৩ গ্রিড)
          IgnorePointer(
            child: CustomPaint(size: Size.infinite, painter: GridPainter()),
          ),

          // ৩. ফ্রেম লাইট (সাদা আলোকিত বর্ডার)
          if (_isLightOn)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 25,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

          // ৪. টপ গ্লাস প্যানেল (Glassmorphism UI)
          Positioned(top: 50, left: 15, right: 15, child: _buildTopPanel()),

          // ৫. সেন্টার টাচ আইকন
          Center(
            child: Icon(
              Icons.touch_app_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 55,
            ),
          ),

          // ৬. নিচে শুধু একটি টেক্সট স্টাইল (যেখানে পরে অ্যাড বসবে)
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "SMART MIRROR PRO",
                style: TextStyle(
                  color: Colors.white24,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Text(
                "ZOOM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    trackHeight: 1.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: _zoomLevel,
                    min: 1.0,
                    max: 5.0,
                    onChanged: (v) {
                      setState(() => _zoomLevel = v);
                      _logic.controller!.setZoomLevel(v);
                    },
                  ),
                ),
              ),
              _circularButton(Icons.pause, () {}),
              const SizedBox(width: 12),
              _circularButton(
                _isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                () {
                  setState(() => _isLightOn = !_isLightOn);
                  _isLightOn
                      ? ScreenBrightness().setScreenBrightness(1.0)
                      : ScreenBrightness().resetScreenBrightness();
                },
                isActive: _isLightOn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circularButton(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// গ্রিড আঁকার পেইন্টার
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;
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
