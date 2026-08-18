import 'package:camera/camera.dart';

class MirrorLogic {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Future<void> initCamera() async {
    cameras = await availableCameras();
    // front camera select
    final front = cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    controller = CameraController(
      front,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  void dispose() {
    controller?.dispose();
  }
}
