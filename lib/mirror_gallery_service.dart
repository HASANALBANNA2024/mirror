import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class MirrorGalleryService {

  // ১. ছবি সেভ করার ফাংশন (Freeze থাকা অবস্থায় কল হবে)
  static Future<void> saveSnapshot(BuildContext context, dynamic controller) async {
    try {
      if (controller == null || !controller.value.isInitialized) {
        debugPrint("Camera controller not ready");
        return;
      }

      // ছবি তুলবে
      final image = await controller.takePicture();

      // gal প্যাকেজ দিয়ে গ্যালারিতে সেভ করবে
      await Gal.putImage(image.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Saved to Gallery!"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving image: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save image"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // ২. ইন-অ্যাপ গ্যালারি (Horizontal/Side Scroll)
  static Widget buildInAppGallery({required VoidCallback onClose}) {
    return Container(
      height: 200, // গ্যালারির উচ্চতা নির্ধারণ
      color: const Color(0xFF0D0D0D), // ডার্ক থিম
      child: Column(
        children: [
          // হেডার: টাইটেল এবং ক্লোজ বাটন
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "SAVED LOOKS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 11,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.white54, size: 20),
                ),
              ],
            ),
          ),

          // সাইড স্ক্রোলিং গ্রিড (একসাথে ৩টি ছবি দেখাবে)
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal, // পাশাপাশি স্ক্রোল হবে
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // এক সারিতে ১টি (যেহেতু হরিজন্টাল, তাই এটি উচ্চতা নিয়ন্ত্রণ করে)
                mainAxisSpacing: 12, // ছবির মাঝের গ্যাপ
                childAspectRatio: 1.3, // ছবির উইডথ নিয়ন্ত্রণ করবে
              ),
              itemCount: 10, // এখানে আপনার ইমেজের লিস্ট বসবে
              itemBuilder: (context, index) {
                return Container(
                  width: 120, // প্রতি ছবির চওড়া
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: const Center(
                      child: Icon(Icons.photo_library_outlined, color: Colors.white12, size: 30),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}