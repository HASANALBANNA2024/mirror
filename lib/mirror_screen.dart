import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'mirror_settings_panel.dart';
import 'mirror_frame_widgets.dart';
import 'mirror_gallery_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ডাটা সেভ করার জন্য
import 'mirror_widgets.dart';

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // জুম সিঙ্ক করার জন্য কন্ট্রোলার (UI পরিবর্তন করবে না)
  final TransformationController _zoomController = TransformationController();

  double _zoomLevel = 1.0;
  bool _isLightOn = false;
  bool _isFrozen = false;
  bool _showHandIcon = false;
  bool _showGrid = true;
  bool _isFullscreen = false;

  bool _isSettingsOpen = false;
  bool _isGalleryOpen = false;
  String _activeMode = "HD VIEW";

  Color _overlayColor = Colors.transparent;
  double _exposureLevel = 0.0;
  int _timerValue = 0;
  int _currentCountdown = 0;

  List<String> _capturedImages = [];
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadImagesFromDisk(); // অ্যাপ খুললে পুরনো ছবি লোড হবে
  }

  // ১. ইমেজ লিস্ট ফোনে সেভ করার লজিক
  Future<void> _saveImagesToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('captured_images', _capturedImages);
  }

  // ২. ফোন থেকে ইমেজ লিস্ট লোড করার লজিক
  Future<void> _loadImagesFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedImages = prefs.getStringList('captured_images');
    if (savedImages != null) {
      setState(() => _capturedImages = savedImages);
    }
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

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _zoomController.dispose();
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

  void _onCaptureTap() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;

      if (_timerValue > 0) {
        for (int i = _timerValue; i > 0; i--) {
          if (!mounted) return;
          setState(() => _currentCountdown = i);
          await Future.delayed(const Duration(seconds: 1));
        }
        setState(() => _currentCountdown = 0);
      }

      String? path = await MirrorGalleryService.saveSnapshot(context, _controller);

      if (path != null) {
        setState(() => _capturedImages.add(path));
        await _saveImagesToDisk(); // ছবি তোলার পর লিস্ট সেভ
      }

    } catch (e) {
      debugPrint("Capture Error: $e");
      setState(() => _currentCountdown = 0);
    }
  }

  void _onMirrorTap() {
    setState(() {
      // ট্যাপ করলে জুম লজিক
      if (_zoomLevel < 5.0) {
        _zoomLevel += 1.0;
      } else {
        _zoomLevel = 1.0;
      }
      _zoomController.value = Matrix4.identity()..scale(_zoomLevel);
      _controller?.setZoomLevel(_zoomLevel);
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
                    // ২ আঙুলে জুম লজিক যা UI এর ক্ষতি করবে না
                    InteractiveViewer(
                      transformationController: _zoomController,
                      minScale: 1.0,
                      maxScale: 5.0,
                      onInteractionUpdate: (details) {
                        if (details.scale != 1.0) {
                          setState(() {
                            _zoomLevel = _zoomController.value.getMaxScaleOnAxis().clamp(1.0, 5.0);
                            _controller?.setZoomLevel(_zoomLevel);
                          });
                        }
                      },
                      child: _buildMirrorFrame(),
                    ),

                    if (_currentCountdown > 0)
                      Center(
                        child: IgnorePointer(
                          child: Text(
                            "$_currentCountdown",
                            style: TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [Shadow(blurRadius: 15, color: Colors.black54, offset: Offset(2, 4))],
                            ),
                          ),
                        ),
                      ),

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
                selectedPaths: _selectedImages,
                onClose: () {
                  setState(() {
                    _isGalleryOpen = false;
                    _selectedImages.clear();
                  });
                },
                onLongPress: (path) {
                  setState(() {
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
                  }
                },
                onDeleteAll: () {
                  setState(() {
                    _capturedImages.removeWhere((item) => _selectedImages.contains(item));
                    _selectedImages.clear();
                  });
                  _saveImagesToDisk(); // ডিলিট করার পর স্টোরেজ আপডেট
                },
                onShareAll: () async {
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
                    _zoomController.value = Matrix4.identity()..scale(_zoomLevel);
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
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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

          GestureDetector(
            onTap: _onCaptureTap,
            child: Container(
              width: 35,
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
                  Icons.camera_alt,
                  color: Color(0xFF121212),
                  size: 30,
                ),
              ),
            ),
          ),

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