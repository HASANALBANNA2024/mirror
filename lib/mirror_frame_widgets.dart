import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'mirror_widgets.dart';

class MirrorFrameView extends StatelessWidget {
  final bool isLightOn;
  final bool showHandIcon;
  final VoidCallback onTap;
  final Future<void>? initializeControllerFuture;
  final CameraController? controller;
  final Widget gridLines;

  final bool showGrid;
  final VoidCallback onGridToggle;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const MirrorFrameView({
    super.key,
    required this.isLightOn,
    required this.showHandIcon,
    required this.onTap,
    required this.initializeControllerFuture,
    this.controller,
    required this.gridLines,
    required this.showGrid,
    required this.onGridToggle,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return AuraMirrorBorder(
      isLightOn: isLightOn,
      activeColor: const Color(0xFFFFF4D2),
      child: Stack(
        children: [
          // Realistic Mirror base
          GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: FutureBuilder<void>(
                future: initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      controller != null) {
                    return Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        // ---Camera HD ---
                        ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit:
                                  BoxFit.cover, // sharp and full screen to view
                              child: SizedBox(
                                // to maintain sensor original view
                                width: controller!.value.previewSize!.height,
                                height: controller!.value.previewSize!.width,
                                child: CameraPreview(controller!),
                              ),
                            ),
                          ),
                        ),

                        if (showGrid) gridLines,
                        _buildRealisticGlassLayer(),
                        _buildHandIcon(),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.white12,
                    ),
                  );
                },
              ),
            ),
          ),

          // smart grid switch
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onGridToggle,
              child: Opacity(
                opacity: 0.5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 34,
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: showGrid ? Colors.white : Colors.black38,
                    border: Border.all(color: Colors.white10, width: 0.5),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    // logic to grid switch
                    alignment: showGrid
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: showGrid ? Colors.black : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ৩. ফুলস্ক্রিন টেক্সট
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: onToggleFullscreen,
              child: Text(
                isFullscreen ? "DEFAULT" : "FULLSCREEN",
                style: TextStyle(
                  color: Colors.black.withOpacity(1.0),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticGlassLayer() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
            colors: [
              Colors.white.withOpacity(0.04),
              Colors.transparent,
              Colors.transparent,
              Colors.white.withOpacity(0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandIcon() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: showHandIcon ? 1.0 : 0.0,
      child: Icon(
        Icons.touch_app_outlined,
        color: Colors.white.withOpacity(0.6),
        size: 50,
      ),
    );
  }
}
