import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart'; // ছবি সেভ করার জন্য
import 'package:share_plus/share_plus.dart';

class MirrorGalleryService {

  // ১. ইমেজ সেভ করার ফাংশন (এটি না থাকায় আপনার মেইন ফাইলে লাল দাগ আসছিল)
  static Future<String?> saveSnapshot(BuildContext context, dynamic controller) async {
    try {
      if (controller == null || !controller.value.isInitialized) return null;

      // ছবি তুলবে
      final image = await controller.takePicture();

      // ফোনের গ্যালারিতে সেভ করবে
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
      return image.path; // ছবির পাথ রিটার্ন করবে যাতে লিস্টে অ্যাড করা যায়
    } catch (e) {
      debugPrint("Save Error: $e");
      return null;
    }
  }

  // ২. ইন-অ্যাপ গ্যালারি উইজেট (মাল্টি-সিল্যাক্ট, শেয়ার এবং ডিলিট সহ)
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
      height: 180, // আপনার চাহিদা মতো হাইট সেট করা হয়েছে
      color: Colors.black.withOpacity(0.95),
      child: Column(
        children: [
          // টুলবার সেকশন
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectedPaths.isEmpty
                    ? const Text("GALLERY", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))
                    : Text("${selectedPaths.length} SELECTED", style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),

                Row(
                  children: [
                    if (selectedPaths.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.blueAccent, size: 18),
                        onPressed: onShareAll,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                        onPressed: onDeleteAll,
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ইমেজ গ্রিড/লিস্ট
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                // নতুন ছবিগুলো আগে দেখানোর জন্য reversed ব্যবহার করা হয়েছে
                String path = imagePaths.reversed.toList()[index];
                bool isSelected = selectedPaths.contains(path);

                return GestureDetector(
                  onLongPress: () => onLongPress(path),
                  onTap: () => onTap(path),
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100, // বক্সের সাইজ মিডিয়াম রাখা হয়েছে
                        margin: const EdgeInsets.only(right: 10, bottom: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.white10,
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
                            child: Icon(Icons.check, size: 10, color: Colors.white),
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