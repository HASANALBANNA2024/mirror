import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class MirrorGalleryService {
  static Future<String?> saveSnapshot(
    BuildContext context,
    dynamic controller,
  ) async {
    try {
      if (controller == null || !controller.value.isInitialized) return null;
      final image = await controller.takePicture();
      await Gal.putImage(image.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Captured & Saved!"),
            duration: Duration(milliseconds: 700),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return image.path;
    } catch (e) {
      debugPrint("Save Error: $e");
      return null;
    }
  }

  static Widget buildInAppGallery({
    required List<String> imagePaths,
    required List<String> selectedPaths,
    required VoidCallback onClose,
    required Function(String) onLongPress,
    required Function(String) onTap,
    required VoidCallback onDeleteAll,
    required VoidCallback onShareAll,
  }) {
    return Container(
      height: 180,
      color: Colors.black.withOpacity(0.95),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedPaths.isEmpty
                    ? const Text(
                        "GALLERY",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      )
                    : Text(
                        "${selectedPaths.length} SELECTED",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                Row(
                  children: [
                    if (selectedPaths.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.blueAccent,
                          size: 18,
                        ),
                        onPressed: onShareAll,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        onPressed: onDeleteAll,
                      ),
                    ],
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                // new picture first display
                List<String> reversedList = imagePaths.reversed.toList();
                String path = reversedList[index];
                bool isSelected = selectedPaths.contains(path);

                return GestureDetector(
                  onLongPress: () => onLongPress(path),
                  onTap: () {
                    if (selectedPaths.isNotEmpty) {
                      onTap(path); // Selection mode on
                    } else {
                      // no selection full screen view
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            imagePaths: reversedList,
                            initialIndex: index,
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        margin: const EdgeInsets.only(right: 10, bottom: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.white10,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(File(path), fit: BoxFit.cover),
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: 5,
                          right: 15,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- full screen viewer (Swipeable) ---
class FullScreenImageViewer extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(imagePaths[index]),
                fit: BoxFit.contain, // full screen to image
              ),
            ),
          );
        },
      ),
    );
  }
}
