import 'dart:async';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_candy.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_hook.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_player.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_rope.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_scissors.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_star.dart';

class CutTheRopeGame extends Forge2DGame
    with PanDetector, HasCollisionDetection {
  final images = Images(prefix: "assets/cuttherope/sprites/");

  late CTRPlayer _player;
  CTRScissors? _currentScissors;
  @override
  FutureOr<void> onLoad() async {
    world.gravity = Vector2(0, 1000);
    final bgSprite = await Sprite.load("bgr_01_hd.jpeg",
        images: images,
        srcSize: Vector2(770, 1036),
        srcPosition: Vector2(0, 0));
    final bgComponent = SpriteComponent(sprite: bgSprite)
      ..anchor = Anchor.center
      ..position = Vector2(size.x * 0.5, size.y * 0.5);
    add(bgComponent);

    _player = CTRPlayer(images: images)
      ..anchor = Anchor.center
      ..position = Vector2(size.x * 0.8, size.y * 0.8);
    add(_player);

    add(CTRStar(images: images)
      ..anchor = Anchor.center
      ..position = Vector2(100, 400));

    add(CTRStar(images: images)
      ..anchor = Anchor.center
      ..position = Vector2(220, 430));

    add(CTRStar(images: images)
      ..anchor = Anchor.center
      ..position = Vector2(320, 530));

    final candy = CTRCandy(images: images, pos: Offset(100, 200));

    {
      final hook = CTRHook(images: images)
        ..anchor = Anchor.center
        ..position = Vector2(100, 100);
      final rope = CTRRope(
          startPosition: hook.position.toOffset(),
          attachComponent: candy,
          length: 200);
      add(rope);
      add(hook);
    }

    {
      final hook = CTRHook(images: images)
        ..anchor = Anchor.center
        ..position = Vector2(250, 100);
      final rope = CTRRope(
          startPosition: hook.position.toOffset(),
          attachComponent: candy,
          length: 300);
      add(rope);
      add(hook);
    }

    add(candy);
    return super.onLoad();
  }

  @override
  void onPanStart(DragStartInfo info) {
    super.onPanStart(info);
    _currentScissors = CTRScissors();
    add(_currentScissors!);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    if (_currentScissors != null) {
      _currentScissors!.updatePosition(info.eventPosition.global);
    }
  }

  @override
  void onPanCancel() {
    super.onPanCancel();
    if (_currentScissors != null) {
      remove(_currentScissors!);
      _currentScissors = null;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    if (_currentScissors != null) {
      remove(_currentScissors!);
      _currentScissors = null;
    }
  }
}
