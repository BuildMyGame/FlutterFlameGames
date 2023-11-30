import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/flappybird/flappybird_game.dart';

class FlappyBirdPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          const GameWidget.controlled(gameFactory: FlappyBirdGame.new),
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
