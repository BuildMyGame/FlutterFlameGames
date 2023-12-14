import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/cuttherope/cut_the_rope_page.dart';
import 'package:flutter_flame_games/games/fallblocks/fallblocks_page.dart';
import 'package:flutter_flame_games/games/flappybird/flappybird_page.dart';

class GameItem {
  final String? icon;
  final String? title;
  final RoutePageBuilder? pageBuilder;
  const GameItem({this.icon, this.title, this.pageBuilder});
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final games = [
    GameItem(
      icon: "assets/flappybird/sprites/redbird-midflap.png",
      title: "Flappy Bird",
      pageBuilder: (context, animation, secondaryAnimation) {
        return FlappyBirdPage();
      },
    ),
    GameItem(
      icon: "assets/cuttherope/sprites/icon.png",
      title: "Cut the Rope",
      pageBuilder: (context, animation, secondaryAnimation) {
        return CutTheRopePage();
      },
    ),
    GameItem(
      icon: "assets/fallblocks/sprites/icon.jpg",
      title: "Fall Blocks",
      pageBuilder: (context, animation, secondaryAnimation) {
        return FallBlocksPage();
      },
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Flame Games"),
      ),
      body: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, idx) {
            return GestureDetector(
              onTap: () {
                final gameInfo = games[idx];
                Navigator.of(context)
                    .push(PageRouteBuilder(pageBuilder: gameInfo.pageBuilder!));
              },
              child: buildItem(idx),
            );
          }),
    );
  }

  Widget buildItem(int idx) {
    final gameInfo = games[idx];
    return Container(
      margin: const EdgeInsets.all(13),
      padding: const EdgeInsets.all(6),
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.0 / MediaQuery.of(context).devicePixelRatio),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            gameInfo.icon ?? "",
            width: 30,
            height: 30,
          ),
          const SizedBox(
            width: 13,
            height: 1,
          ),
          Expanded(
              child: Text(
            gameInfo.title ?? "",
            style: Theme.of(context).primaryTextTheme.bodyMedium,
          )),
          Icon(
            Icons.play_arrow_rounded,
            color: Theme.of(context).primaryTextTheme.bodyMedium?.color ??
                Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}
