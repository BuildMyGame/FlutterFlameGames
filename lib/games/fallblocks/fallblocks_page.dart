import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/fallblocks/fallblocks_game.dart';
import 'package:flutter_flame_games/games/flappybird/flappybird_game.dart';

class FallBlocksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FallBlocksPageState();
}

class _FallBlocksPageState extends State<FallBlocksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          const GameWidget.controlled(gameFactory: FallBlocksGame.new),
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
