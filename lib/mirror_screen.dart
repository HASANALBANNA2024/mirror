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
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 1.5,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.08),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white70,
          size: 18,
        ),
      ),
    );
  }

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: const Text(
        "EXPLORE LA MER'S SIGNATURE REGIMEN: EXCLUSIVE OFFER",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 7,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomSystemBar() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.crop_original,
              color: Colors.white38,
              size: 20,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
