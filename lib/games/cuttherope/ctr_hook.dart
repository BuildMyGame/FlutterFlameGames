//[{"x":2,"y":2,"M":50,"U":50.4},{"x":2,"y":55,"M":14.8,"U":14}]
// hook

import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class CTRHook extends PositionComponent {
  final Images? images;
  CTRHook({this.images});

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(50, 50);

    final hookBg = await Sprite.load("obj_hook_01.png",
        images: images, srcPosition: Vector2(2, 2), srcSize: Vector2(50, 50));
    final hookBgComponent = SpriteComponent(sprite: hookBg)
      ..anchor = Anchor.topLeft
      ..position = Vector2(0, 0);
    add(hookBgComponent);

    final hookFg = await Sprite.load("obj_hook_01.png",
        images: images, srcPosition: Vector2(2, 55), srcSize: Vector2(15, 14));
    final hookFgComponent = SpriteComponent(sprite: hookFg)
      ..anchor = Anchor.center
      ..position = Vector2(25, 25);
    add(hookFgComponent);

    return super.onLoad();
  }
}
