import 'package:flutter/material.dart';

class MirrorSettingsPanel extends StatelessWidget {
  final bool isOpen;
  final String activeMode;
  final Function(String) onModeChanged;

  const MirrorSettingsPanel({
    super.key,
    required this.isOpen,
    required this.activeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Camera mode list
    final List<String> modes = [
      "WARM LIGHT",
      "COLD LIGHT",
      "3S TIMER",
      "5S TIMER",
      "HD VIEW",
      "LOW LIGHT",
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      // settings open to length height
      height: isOpen ? 90 : 0,
      width: double.infinity,
      color: Colors.black, // phone camera dark theme
      child: isOpen
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // mode indicator yellow icon
                const Icon(Icons.arrow_drop_up, color: Colors.yellow, size: 14),

                // Horizontal text list
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: modes.length,
                    itemBuilder: (context, index) {
                      final mode = modes[index];
                      final bool isActive = activeMode == mode;

                      return GestureDetector(
                        onTap: () => onModeChanged(mode),
                        behavior: HitTestBehavior
                            .opaque, // gape click to work of function
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            mode,
                            style: TextStyle(
                              // active mode of setting features
                              color: isActive ? Colors.yellow : Colors.white54,
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),
                // small slider indicator
                Container(
                  width: 35,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
