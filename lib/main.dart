import 'package:flutter/material.dart';

import 'mirror_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MirrorApp());
}

class MirrorApp extends StatelessWidget {
  const MirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const MirrorScreen(),
    );
  }
}
