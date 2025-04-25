import 'package:flutter/material.dart';
import 'game/game_board.dart';

void main() {
  runApp(const CalamarApp());
}

class CalamarApp extends StatelessWidget {
  const CalamarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameBoard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
