import 'package:flutter/material.dart';
import 'package:flutter_flame_games/home_page.dart';

void main() {
  runApp(const FlutterFlameApp());
}

class FlutterFlameApp extends StatelessWidget {
  const FlutterFlameApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flame Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
