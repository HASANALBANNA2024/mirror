import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class MirrorGalleryService {

  // ১. ইমেজ সেভ করার ফাংশন (যা আপনার এররটি ফিক্স করবে)
  static Future<String?> saveSnapshot(BuildContext context, dynamic controller) async {
    try {
      if (controller == null || !controller.value.isInitialized) return null;

      final image = await controller.takePicture();
      await Gal.putImage(image.path); // ফোনের গ্যালারিতে সেভ হবে

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

  // ২. ইন-অ্যাপ গ্যালারি (বক্সের উচ্চতা ১০০-এর নিচে করা হয়েছে)
  static Widget buildInAppGallery({
    required List<String> imagePaths,
    required VoidCallback onClose
  }) {
    return Container(
      height: 100, // উচ্চতা ১০০ করে দেওয়া হয়েছে আপনার রিকোয়েস্ট অনুযায়ী
      color: Colors.black.withOpacity(0.9),
      child: Column(
        children: [
          // ছোট ক্লোজ বাটন বার
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: double.infinity,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
            ),
          ),

          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                // নতুন ছবিগুলো আগে দেখাবে
                String path = imagePaths.reversed.toList()[index];
                return Container(
                  width: 60, // উইডথ আরও কমানো হয়েছে
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(File(path), fit: BoxFit.cover),
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