import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/cuttherope/cut_the_rope_game.dart';

class CutTheRopePage extends StatefulWidget {
  CutTheRopePage({super.key});
  @override
  State<StatefulWidget> createState() => _CutTheRopePageState();
}

class _CutTheRopePageState extends State<CutTheRopePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          const GameWidget.controlled(gameFactory: CutTheRopeGame.new),
          Positioned(
              left: 16,
              top: 60,
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  )))
        ],
      ),
    );
  }
}
