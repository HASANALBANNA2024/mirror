import 'package:flutter/material.dart';

import 'mirror_widgets.dart';

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  double _zoomLevel = 1.0;
  bool _isLightOn = false;
  bool _isFrozen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // ১. হেডার এবং কন্ট্রোল প্যানেল (সব এক সারিতে)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
              child: Row(
                children: [
                  // জুম স্লাইডার সেকশন
                  _buildCompactZoomSection(),

                  const SizedBox(width: 10),

                  // লাইট এবং ফ্রিজ বাটন (আইকন বাটন)
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

            // ২. মেইন মিরর ফ্রেম (দুই পাশের গ্যাপ কমানো হয়েছে)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: _buildMirrorFrame(),
              ),
            ),

            // ৩. অ্যাড ব্যানার (স্লিম)
            _buildAdBanner(),

            // ৪. বটম সিস্টেম বার
            _buildBottomSystemBar(),
          ],
        ),
      ),
    );
  }

  // --- কাস্টম উইজেট সেকশন ---

  // জুম স্লাইডার (একদম ক্লিন ডিজাইন)
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
                inactiveTrackColor: Colors.white,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: _zoomLevel,
                min: 1.0,
                max: 5.0,
                onChanged: (v) => setState(() => _zoomLevel = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ছোট আইকন বাটন (Light & Freeze এর জন্য)
  Widget _buildSmallIconButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, // বাটনের উইডথ ফিক্সড করা হলো
        height: 42, // বাটনের হাইট ফিক্সড করা হলো
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // বক্স আকৃতির জন্য borderRadius ব্যবহার করা হয়েছে
          borderRadius: BorderRadius.circular(12),

          // ৩ডি ব্ল্যাক ইফেক্টের জন্য গ্রিডিয়েন্ট
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.white, Colors.white] // অ্যাক্টিভ থাকলে সলিড সাদা
                : [
                    const Color(0xFF2C2C2C), // হালকা ব্ল্যাক (ওপরে)
                    const Color(0xFF000000), // গাঢ় ব্ল্যাক (নিচে)
                  ],
          ),

          // ৩ডি লুক দেওয়ার জন্য শ্যাডো
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            if (!isActive)
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                offset: const Offset(-1, -1),
                blurRadius: 2,
              ),
          ],

          // বর্ডারটি আরও ক্লিয়ার করার জন্য
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            // আইকন আরও ক্লিয়ার করার জন্য কালার এবং সাইজ অ্যাডজাস্টমেন্ট
            color: isActive ? Colors.black : Colors.white.withOpacity(0.9),
            size: 20, // আইকন সাইজ সামান্য বাড়ানো হয়েছে ক্লারিটির জন্য
          ),
        ),
      ),
    );
  }

  // mirror frame
  Widget _buildMirrorFrame() {
    return AuraMirrorBorder(
      isLightOn: _isLightOn,
      activeColor: const Color(0xFFFFF4D2),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(
              child: Icon(
                Icons.touch_app_outlined,
                color: Colors.white10,
                size: 50,
              ),
            ),
            _buildGridLines(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLines() {
    return IgnorePointer(
      child: CustomPaint(size: Size.infinite, painter: GridPainter()),
    );
  }

  Widget _buildAdBanner() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ফ্রেম এবং ব্যানারের মাঝে হালকা গ্যাপ (৫ পিক্সেল)
        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          height: 50, // AdMob Standard Banner সাইজ
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "EXPLORE LA MER'S SIGNATURE REGIMEN: EXCLUSIVE OFFER",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSystemBar() {
    return SizedBox(
      width: double.infinity,
      height: 30, // হাইট ৪০ থেকে কমিয়ে ৩০ করা হয়েছে
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // গ্যালারি আইকন
          IconButton(
            padding: EdgeInsets.zero, // বাড়তি স্পেস কমানোর জন্য
            onPressed: () {},
            icon: const Icon(
              Icons.crop_original,
              color: Colors.white, // কালার আরও ক্লিয়ার করা হয়েছে
              size: 24, // আইকন সাইজ ২০ থেকে বাড়িয়ে ২৪ করা হয়েছে
            ),
          ),

          // মাঝখানের কাস্টম সার্কেল বাটন
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 1.5),
              ),
              child: Container(
                width: 18, // ইনার সার্কেল ১৪ থেকে ১৮ করা হয়েছে
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // সেটিংস আইকন
          IconButton(
            padding: EdgeInsets.zero, // বাড়তি স্পেস কমানোর জন্য
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white, // কালার আরও ক্লিয়ার করা হয়েছে
              size: 24, // আইকন সাইজ ২০ থেকে বাড়িয়ে ২৪ করা হয়েছে
            ),
          ),
        ],
      ),
    );
  }
}
