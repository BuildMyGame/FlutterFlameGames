import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_player.dart';

class CutTheRopeGame extends Forge2DGame {
  final images = Images(prefix: "assets/cuttherope/sprites/");

  late CTRPlayer _player;
  @override
  FutureOr<void> onLoad() {
    _player = CTRPlayer(images:images)..position = Vector2(100, 100);
    add(_player);
    return super.onLoad();
  }
}