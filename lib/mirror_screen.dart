import 'dart:io'; // এটি অবশ্যই যোগ করবেন File ব্যবহারের জন্য
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'mirror_settings_panel.dart';
import 'mirror_frame_widgets.dart';
import 'mirror_gallery_service.dart';
import 'package:share_plus/share_plus.dart';
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
  int _currentCountdown = 0;


  // --- আপনার জন্য নতুন লিস্ট (গ্যালারি ইমেজ সেভ করার জন্য) ---
  List<String> _capturedImages = [];
  List<String> _selectedImages = [];

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

  void _handleModeChange(String newMode) {
    setState(() {
      _activeMode = newMode;
      _overlayColor = Colors.transparent;
      _exposureLevel = 0.0;
      _timerValue = 0;

      switch (newMode) {
        case "WARM LIGHT":
          _overlayColor = Colors.orange.withOpacity(0.12);
          _exposureLevel = 0.3;
          break;
        case "COLD LIGHT":
          _overlayColor = Colors.blue.withOpacity(0.08);
          _exposureLevel = 0.2;
          break;
        case "3S TIMER":
          _timerValue = 3;
          break;
        case "5S TIMER":
          _timerValue = 5;
          break;
        case "LOW LIGHT":
          _exposureLevel = 1.2;
          break;
        case "HD VIEW":
          _exposureLevel = 0.0;
          break;
      }
    });

    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.setExposureOffset(_exposureLevel);
    }
  }

  // --- ক্যাপচার (মাঝখানের বাটন) লজিক আপডেট ---
  void _onCaptureTap() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      // ১. যদি টাইমার ভ্যালু ০ এর বেশি হয় (৩ বা ৫ সেকেন্ড)
      if (_timerValue > 0) {
        for (int i = _timerValue; i > 0; i--) {
          if (!mounted) return;

          setState(() {
            _currentCountdown = i; // স্ক্রিনের মাঝখানে দেখানোর জন্য স্টেট আপডেট
          });

          // ১ সেকেন্ড অপেক্ষা করবে
          await Future.delayed(const Duration(seconds: 1));
        }

        // টাইমার শেষ হলে ০ করে দিবে যাতে স্ক্রিন থেকে সংখ্যাটি চলে যায়
        setState(() {
          _currentCountdown = 0;
        });
      }

      // ২. ইমেজ সেভ করা এবং পাথ নেয়া
      String? path = await MirrorGalleryService.saveSnapshot(context, _controller);

      if (path != null) {
        setState(() {
          _capturedImages.add(path); // গ্যালারি লিস্ট আপডেট হবে
        });
      }

    } catch (e) {
      debugPrint("Capture Error: $e");
      setState(() => _currentCountdown = 0); // এরর হলেও টাইমার রিসেট
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
                      icon: _isFrozen ? Icons.play_arrow : Icons.pause,
                      isActive: _isFrozen,
                      onTap: () async {
                        if (_controller == null || !_controller!.value.isInitialized) return;
                        try {
                          if (_isFrozen) {
                            await _controller!.resumePreview();
                            setState(() => _isFrozen = false);
                          } else {
                            await _controller!.pausePreview();
                            setState(() => _isFrozen = true);
                          }
                        } catch (e) {
                          debugPrint("Freeze error: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              flex: _isGalleryOpen ? 5 : 10,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isFullscreen ? 0 : 5,
                  vertical: 0,
                ),
                child: Stack(
                  children: [
                    _buildMirrorFrame(),
                    // timer count
                    if (_currentCountdown > 0)
                      Center( // এটি হরাইজন্টাল এবং ভার্টিক্যাল সেন্টার নিশ্চিত করে
                        child: IgnorePointer(
                          child: Text(
                            "$_currentCountdown",
                            style: TextStyle(
                              fontSize: 120, // আপনার চাহিদা মতো বড় সাইজ
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  blurRadius: 15,
                                  color: Colors.black54,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // timer count end
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

            if (_isGalleryOpen)
              MirrorGalleryService.buildInAppGallery(
                imagePaths: _capturedImages,
                selectedPaths: _selectedImages, // এটি আপনার নতুন লিস্ট
                onClose: () {
                  setState(() {
                    _isGalleryOpen = false;
                    _selectedImages.clear(); // বন্ধ করলে সিলেকশন মুছে যাবে
                  });
                },
                onLongPress: (path) {
                  setState(() {
                    // লং প্রেস করলে সিলেক্ট হবে
                    if (_selectedImages.contains(path)) {
                      _selectedImages.remove(path);
                    } else {
                      _selectedImages.add(path);
                    }
                  });
                },
                onTap: (path) {
                  if (_selectedImages.isNotEmpty) {
                    setState(() {
                      if (_selectedImages.contains(path)) {
                        _selectedImages.remove(path);
                      } else {
                        _selectedImages.add(path);
                      }
                    });
                  } else {
                    // এখানে চাইলে সিঙ্গেল ট্যাপে ছবি বড় করে দেখার লজিক দিতে পারেন
                    debugPrint("Single tap on: $path");
                  }
                },
                onDeleteAll: () {
                  setState(() {
                    // সিলেক্ট করা সব ছবি একসাথে ডিলিট
                    _capturedImages.removeWhere((item) => _selectedImages.contains(item));
                    _selectedImages.clear();
                  });
                },
                onShareAll: () async {
                  // সিলেক্ট করা সব ছবি একসাথে শেয়ার
                  if (_selectedImages.isNotEmpty) {
                    final files = _selectedImages.map((path) => XFile(path)).toList();
                    await Share.shareXFiles(files);
                  }
                },
              )
            else if (!_isFullscreen) ...[
              _isSettingsOpen
                  ? MirrorSettingsPanel(
                isOpen: _isSettingsOpen,
                activeMode: _activeMode,
                onModeChanged: (mode) => _handleModeChange(mode),
              )
                  : _buildAdBanner(),
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
      height: 45, // একটু হাইট বাড়ানো হয়েছে থাম্বনেইল দেখানোর জন্য
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // বাম পাশের গ্যালারি আইকন (এখানে শেষ তোলা ছবি দেখাবে)
          GestureDetector(
            onTap: () => setState(() => _isGalleryOpen = !_isGalleryOpen),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
                image: _capturedImages.isNotEmpty
                    ? DecorationImage(
                    image: FileImage(File(_capturedImages.last)),
                    fit: BoxFit.cover
                )
                    : null,
              ),
              child: _capturedImages.isEmpty
                  ? const Icon(Icons.crop_original, color: Colors.white, size: 18)
                  : null,
            ),
          ),

          // ২. মাঝখানের ক্যামেরা বাটন (ক্যাপচার)
          GestureDetector(
            onTap: _onCaptureTap,
            child: Container(
              width: 35, // আইকনটি সুন্দরভাবে দেখানোর জন্য সাইজ একটু বাড়ানো হয়েছে
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: Colors.white12, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_alt, // ক্যামেরা আইকন যোগ করা হয়েছে
                  color: Color(0xFF121212), // ব্যাকগ্রাউন্ডের সাথে ম্যাচ করে ডার্ক কালার
                  size: 30,
                ),
              ),
            ),
          ),

          // setting icon
          GestureDetector(
            onTap: () {
              setState(() {
                _isSettingsOpen = !_isSettingsOpen;
                _isGalleryOpen = false;
              });
            },
            child: Icon(
              _isSettingsOpen ? Icons.keyboard_arrow_down : Icons.settings_outlined,
              color: _isSettingsOpen ? Colors.yellow : Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}