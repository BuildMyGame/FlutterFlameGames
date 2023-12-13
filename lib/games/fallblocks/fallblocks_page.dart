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
          GameWidget.controlled(
            gameFactory: FallBlocksGame.new,
            overlayBuilderMap: {
              "failed": (context, game) {
                final fallblocksGame = game as FallBlocksGame;
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Expanded(
                            child: Center(
                          child: Text(
                            "分数：${fallblocksGame.score}",
                            style: const TextStyle(fontSize: 30),
                          ),
                        )),
                        GestureDetector(
                          onTap: () {
                            game.overlays.remove("failed");
                            game.reset();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text(
                              "重新开始",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),
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
