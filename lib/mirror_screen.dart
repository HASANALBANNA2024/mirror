import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'mirror_frame_widgets.dart';
import 'mirror_widgets.dart';

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  double _zoomLevel = 1.0;
  bool _isLightOn = false;
  bool _isFrozen = false;
  bool _showHandIcon = false;

  // নতুন ভেরিয়েবলসমূহ
  bool _showGrid = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.max, // সর্বোচ্চ রেজোলিউশন
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      // এরর এড়াতে এবং বেটার ফোকাস পেতে নিচের ব্লকটি ব্যবহার করুন
      if (_controller!.value.isInitialized) {
        try {
          // কিছু ডিভাইসে এটি সরাসরি সাপোর্ট নাও করতে পারে, তাই ট্রাই-ক্যাচ রাখা ভালো
          // continuousVideo এর বদলে auto ট্রাই করুন অথবা চেক করে নিন
          await _controller!.setFocusMode(FocusMode.auto);

          // ExposureMode সাধারণত auto বা locked হয়
          await _controller!.setExposureMode(ExposureMode.auto);
        } catch (e) {
          debugPrint("Focus/Exposure error: $e");
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onMirrorTap() {
    setState(() => _showHandIcon = true);
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
            // ১. হেডার কন্ট্রোল (ফুলস্ক্রিন না থাকলে দেখাবে)
            if (!_isFullscreen)
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

            // ২. মেইন মিরর ফ্রেম (এটি সব সময় থাকবে এবং বাকি জায়গা নেবে)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isFullscreen
                      ? 0
                      : 5, // ফুলস্ক্রিনে সাইড গ্যাপ থাকবে না
                  vertical: 0,
                ),
                child: _buildMirrorFrame(),
              ),
            ),

            // ৩. অ্যাড ব্যানার (ফুলস্ক্রিন না থাকলে দেখাবে)
            if (!_isFullscreen) _buildAdBanner(),

            // ৪. বটম সিস্টেম বার (ফুলস্ক্রিন না থাকলে দেখাবে)
            if (!_isFullscreen) _buildBottomSystemBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMirrorFrame() {
    return MirrorFrameView(
      isLightOn: _isLightOn,
      showHandIcon: _showHandIcon,
      onTap: _onMirrorTap,
      initializeControllerFuture: _initializeControllerFuture,
      controller: _controller,
      gridLines: _buildGridLines(),
      // নতুন প্যারামিটারগুলো এখানে পাস করা হয়েছে
      showGrid: _showGrid,
      onGridToggle: () => setState(() => _showGrid = !_showGrid),
      isFullscreen: _isFullscreen,
      onToggleFullscreen: () => setState(() => _isFullscreen = !_isFullscreen),
    );
  }

  // --- বাকি উইজেটগুলো আগের মতোই থাকবে ---

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
                    _controller?.setZoomLevel(v);
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
            colors: isActive
                ? [Colors.white, Colors.white]
                : [const Color(0xFF2C2C2C), const Color(0xFF000000)],
          ),
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
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: double.infinity,
      height: 50,
      color: Colors.black.withOpacity(0.8),
      alignment: Alignment.center,
      child: const Text(
        "EXPLORE LA MER'S SIGNATURE REGIMEN",
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
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
