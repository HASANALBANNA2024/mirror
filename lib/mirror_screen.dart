import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'mirror_settings_panel.dart';
import 'mirror_frame_widgets.dart';
import 'mirror_gallery_service.dart';
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
  bool _showGrid = true;
  bool _isFullscreen = false;

  // সেটিংস ভেরিয়েবল
  bool _isSettingsOpen = false;
  bool _isGalleryOpen = false;
  String _activeMode = "HD VIEW";

  // ফাংশনাল লজিকের জন্য ভেরিয়েবল
  Color _overlayColor = Colors.transparent;
  double _exposureLevel = 0.0;
  int _timerValue = 0;

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
        ResolutionPreset.max,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (_controller!.value.isInitialized) {
        try {
          await _controller!.setFocusMode(FocusMode.auto);
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

  // --- মোড হ্যান্ডেল করার ফাংশন ---
  void _handleModeChange(String newMode) {
    setState(() {
      _activeMode = newMode;

      // ডিফল্ট ভ্যালু রিসেট
      _overlayColor = Colors.transparent;
      _exposureLevel = 0.0;
      _timerValue = 0;

      switch (newMode) {
        case "WARM LIGHT":
          _overlayColor = Colors.orange.withOpacity(0.12); // হালকা সোনালি আভা
          _exposureLevel = 0.3;
          break;
        case "COLD LIGHT":
          _overlayColor = Colors.blue.withOpacity(0.08); // হালকা নীলচে আভা
          _exposureLevel = 0.2;
          break;
        case "3S TIMER":
          _timerValue = 3;
          break;
        case "5S TIMER":
          _timerValue = 5;
          break;
        case "LOW LIGHT":
          _exposureLevel = 1.2; // অন্ধকার মোডে এক্সপোজার বাড়ানো
          break;
        case "HD VIEW":
          _exposureLevel = 0.0;
          break;
      }
    });

    // ক্যামেরা কন্ট্রোলারে এক্সপোজার সরাসরি আপডেট
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.setExposureOffset(_exposureLevel);
    }
  }

  // --- ক্যাপচার (মাঝখানের বাটন) লজিক ---
  void _onCaptureTap() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      // ১. যদি টাইমার সেট করা থাকে (৩ বা ৫ সেকেন্ড)
      if (_timerValue > 0) {
        for (int i = _timerValue; i > 0; i--) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text("$i", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // ২. টাইমার শেষ হওয়ার পর অথবা টাইমার না থাকলে (০ হলে) সরাসরি ছবি তুলবে
      // MirrorGalleryService থেকে সরাসরি ছবি সেভ করার ফাংশন কল হবে
      await MirrorGalleryService.saveSnapshot(context, _controller);

      // ৩. ছবি তোলার পর হালকা একটি ফ্ল্যাশ ইফেক্ট দিতে পারেন (অপশনাল)
      debugPrint("Image Captured Successfully!");

    } catch (e) {
      debugPrint("Capture Error: $e");
    }
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
            // ১. হেডার কন্ট্রোল (গ্যালারি খোলা থাকলে এটিও হাইড করতে পারেন চাইলে)
            if (!_isFullscreen && !_isGalleryOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
                child: Row(
                  children: [
                    _buildCompactZoomSection(),
                    const SizedBox(width: 10),
                    _buildSmallIconButton(
                      icon: _isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                      isActive: _isLightOn,
                      onTap: () => setState(() => _isLightOn = !_isLightOn),
                    ),
                    const SizedBox(width: 8),
                    _buildSmallIconButton(
                      // ১. ফ্রিজ থাকলে প্লে আইকন দেখাবে, না থাকলে পজ আইকন
                      icon: _isFrozen ? Icons.play_arrow : Icons.pause,
                      isActive: _isFrozen,
                      onTap: () async {
                        // কন্ট্রোলার চেক করা হচ্ছে
                        if (_controller == null || !_controller!.value.isInitialized) return;

                        try {
                          if (_isFrozen) {
                            // ২. যদি চেহারা আটকে থাকে, তবে আবার লাইভ মিরর শুরু হবে
                            await _controller!.resumePreview();
                            setState(() {
                              _isFrozen = false;
                            });
                          } else {
                            // ৩. চেহারা স্ক্রিনে আটকে দিবে (Freeze)
                            // এটি শুধুই প্রিভিউ থামাবে, গ্যালারিতে কোনো ইমেজ সেভ হবে না
                            await _controller!.pausePreview();
                            setState(() {
                              _isFrozen = true;
                            });
                          }
                        } catch (e) {
                          debugPrint("Freeze error: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),

            // ২. মেইন মিরর ফ্রেম (এটি ফ্লেক্সিবল হবে)
            Expanded(
              flex: _isGalleryOpen ? 5 : 10, // গ্যালারি খুললে ক্যামেরা ছোট হয়ে উপরে উঠে যাবে
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isFullscreen ? 0 : 5,
                  vertical: 0,
                ),
                child: Stack(
                  children: [
                    _buildMirrorFrame(),
                    if (_overlayColor != Colors.transparent)
                      IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color: _overlayColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ৩. এই অংশটিই আপনার মূল উত্তর: কন্ডিশনাল গ্যালারি অথবা সেটিংস/অ্যাড
            if (_isGalleryOpen)
              Expanded(
                flex: 5, // গ্যালারি স্ক্রিনের অর্ধেক জায়গা নেবে
                child: MirrorGalleryService.buildInAppGallery(
                  onClose: () => setState(() => _isGalleryOpen = false),
                ),
              )
            else if (!_isFullscreen) ...[
              // ৪. গ্যালারি বন্ধ থাকলে আগের মতো সেটিংস বা অ্যাড দেখাবে
              _isSettingsOpen
                  ? MirrorSettingsPanel(
                isOpen: _isSettingsOpen,
                activeMode: _activeMode,
                onModeChanged: (mode) => _handleModeChange(mode),
              )
                  : _buildAdBanner(),

              // ৫. বটম সিস্টেম বার
              _buildBottomSystemBar(),
            ],
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
      showGrid: _showGrid,
      onGridToggle: () => setState(() => _showGrid = !_showGrid),
      isFullscreen: _isFullscreen,
      onToggleFullscreen: () => setState(() => _isFullscreen = !_isFullscreen),
    );
  }

  Widget _buildCompactZoomSection() {
    return Expanded(
      child: Row(
        children: [
          const Text("ZOOM", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 1.5,
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

  Widget _buildSmallIconButton({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isActive ? [Colors.white, Colors.white] : [const Color(0xFF2C2C2C), const Color(0xFF000000)],
          ),
          border: Border.all(color: isActive ? Colors.white : Colors.white.withOpacity(0.1), width: 0.8),
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 20),
      ),
    );
  }

  Widget _buildGridLines() => IgnorePointer(child: CustomPaint(size: Size.infinite, painter: GridPainter()));

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: double.infinity,
      height: 50,
      color: Colors.black87,
      alignment: Alignment.center,
      child: const Text("EXPLORE PREMIUM FEATURES", style: TextStyle(color: Colors.white54, fontSize: 10)),
    );
  }

  Widget _buildBottomSystemBar() {
    return SizedBox(
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ১. বাম পাশের আইকন (গ্যালারি বা সেভ)
          GestureDetector(
            onTap: () {
              if (_isFrozen) {
                // স্ক্রিন ফ্রিজ থাকলে সরাসরি গ্যালারিতে ছবি সেভ করবে
                MirrorGalleryService.saveSnapshot(context, _controller);
              } else {
                // নরমাল মোডে থাকলে অ্যাপের ভেতরের গ্যালারি ওপেন করবে
                setState(() {
                  _isGalleryOpen = true; // এটি মেইন স্ক্রিনে গ্যালারি দেখাবে
                  _isSettingsOpen = false; // গ্যালারি খুললে সেটিংস বন্ধ করে দেওয়া ভালো
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
              ),
              child: const Icon(Icons.crop_original, color: Colors.white, size: 20),
            ),
          ),

          // ২. মাঝখানের গোল বাটন (ক্যাপচার)
          GestureDetector(
            onTap: _onCaptureTap,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white12, width: 1.5),
              ),
            ),
          ),

          // ৩. ডান পাশের সেটিংস টগল
          GestureDetector(
            onTap: () {
              setState(() {
                _isSettingsOpen = !_isSettingsOpen;
                _isGalleryOpen = false; // সেটিংস খুললে গ্যালারি বন্ধ হয়ে যাবে
              });
            },
            child: Icon(
              _isSettingsOpen ? Icons.keyboard_arrow_down : Icons.settings_outlined,
              color: _isSettingsOpen ? Colors.yellow : Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}