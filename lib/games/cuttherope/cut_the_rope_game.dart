import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_candy.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_hook.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_player.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_rope.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_star.dart';

class CutTheRopeGame extends Forge2DGame with TapCallbacks {
  final images = Images(prefix: "assets/cuttherope/sprites/");

  late CTRPlayer _player;
  @override
  FutureOr<void> onLoad() async {
    world.gravity = Vector2(0, 98);
    // final bgSprite = await Sprite.load("bgr_01_hd.jpeg",
    //     images: images,
    //     srcSize: Vector2(770, 1036),
    //     srcPosition: Vector2(0, 0));
    // final bgComponent = SpriteComponent(sprite: bgSprite)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(size.x * 0.5, size.y * 0.5);
    // add(bgComponent);

    // _player = CTRPlayer(images: images)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(size.x * 0.8, size.y * 0.8);
    // add(_player);

    // final candy = CTRCandy(images: images)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(size.x * 0.5, size.y * 0.5);
    // add(candy);

    // final hook = CTRHook(images: images)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(100, 100);
    // add(hook);

    // final star = CTRStar(images: images)
    //   ..anchor = Anchor.center
    //   ..position = Vector2(size.x * 0.5, 200);
    // add(star);

    final rope = CTRRope(startPosition: Vector2(100, 100));
    add(rope);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _player.eat();
  }
}
