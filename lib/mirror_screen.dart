import 'package:camera/camera.dart'; // এই ইমপোর্টটি অবশ্যই লাগবে
import 'package:flutter/material.dart';

import 'mirror_frame_widgets.dart'; // আপনার নতুন উইজেট ফাইল
import 'mirror_widgets.dart'; // আপনার গ্রিড পেইন্টার এবং Aura উইজেট

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  // --- নতুন লজিক ভেরিয়েবলসমূহ ---
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // --- আপনার আগের ভেরিয়েবলসমূহ ---
  double _zoomLevel = 1.0;
  bool _isLightOn = false;
  bool _isFrozen = false;
  bool _showHandIcon = false;

  @override
  void initState() {
    super.initState();
    _initCamera(); // অ্যাপ ওপেন হলে ক্যামেরা লোড হবে
  }

  // ক্যামেরা সেটআপ লজিক
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // ক্যামেরা রিলিজ করা
    super.dispose();
  }

  void _onMirrorTap() {
    setState(() {
      _showHandIcon = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHandIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // ১. আপনার হেডার এবং কন্ট্রোল প্যানেল
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
              child: Row(
                children: [
                  _buildCompactZoomSection(),
                  const SizedBox(width: 10),
                  _buildSmallIconButton(
                    icon: _isLightOn
                        ? Icons.lightbulb
                        : Icons.lightbulb_outline,
                    isActive: _isLightOn,
                    onTap: () => setState(() => _isLightOn = !_isLightOn),
                  ),
                  const SizedBox(width: 8),
                  _buildSmallIconButton(
                    icon: _isFrozen ? Icons.play_arrow : Icons.pause,
                    isActive: _isFrozen,
                    onTap: () => setState(() => _isFrozen = !_isFrozen),
                  ),
                ],
              ),
            ),

            // ২. মেইন মিরর ফ্রেম (MirrorFrameView কল করা হচ্ছে)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: _buildMirrorFrame(),
              ),
            ),

            // ৩. আপনার অ্যাড ব্যানার
            _buildAdBanner(),

            // ৪. আপনার বটম সিস্টেম বার
            _buildBottomSystemBar(),
          ],
        ),
      ),
    );
  }

  // আপনার Mirror Frame কল
  Widget _buildMirrorFrame() {
    return MirrorFrameView(
      isLightOn: _isLightOn,
      showHandIcon: _showHandIcon,
      onTap: _onMirrorTap,
      initializeControllerFuture: _initializeControllerFuture,
      controller: _controller,
      gridLines: _buildGridLines(),
    );
  }

  // --- আপনার বাকি উইজেটগুলো (ডিজাইন একদম সেম রাখা হয়েছে) ---

  Widget _buildCompactZoomSection() {
    return Expanded(
      child: Row(
        children: [
          const Text(
            "ZOOM",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 1.5,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _zoomLevel,
                min: 1.0,
                max: 5.0,
                onChanged: (v) {
                  setState(() {
                    _zoomLevel = v;
                    _controller?.setZoomLevel(v); // ক্যামেরা জুম হবে
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.white, Colors.white]
                : [const Color(0xFF2C2C2C), const Color(0xFF000000)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGridLines() => IgnorePointer(
    child: CustomPaint(size: Size.infinite, painter: GridPainter()),
  );

  Widget _buildAdBanner() {
    return Column(
      children: [
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 50,
          color: Colors.black.withOpacity(0.8),
          alignment: Alignment.center,
          child: const Text(
            "EXPLORE LA MER'S SIGNATURE REGIMEN",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSystemBar() {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.crop_original, color: Colors.white, size: 24),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
