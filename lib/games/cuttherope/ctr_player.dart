import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_candy.dart';

enum CTRPlayerAnimState { reset, idle1, idle2, eat }

class CTRPlayer extends PositionComponent with CollisionCallbacks {
  final Images? images;
  late List<Sprite> _sprites;
  late SpriteAnimationGroupComponent _animationComponent;
  late SpriteComponent _supportComponent;

  var _lastIdleAnimElapsedTime = 0.0;
  CTRPlayer({this.images});

  @override
  FutureOr<void> onLoad() async {
    final charSize = Vector2(92, 92);

    size = Vector2(110, 110);
    add(RectangleHitbox(size: size));

    // supports
    final supportSprite = await Sprite.load("char_supports.png",
        srcPosition: Vector2(0, 0), srcSize: Vector2(124, 90), images: images);
    _supportComponent = SpriteComponent(sprite: supportSprite)
      ..position = Vector2(-8, 30)
      ..size = Vector2(124, 90);
    add(_supportComponent);

    _sprites = await _genSpriteSlices();

    final animMap = {
      CTRPlayerAnimState.reset: SpriteAnimation.spriteList(
          _sprites.sublist(0, 1),
          stepTime: 0.06,
          loop: true),
      CTRPlayerAnimState.eat: SpriteAnimation.spriteList(
          _sprites.sublist(27, 40),
          stepTime: 0.06,
          loop: false),
      CTRPlayerAnimState.idle1: SpriteAnimation.spriteList(
          _sprites.sublist(64, 83),
          stepTime: 0.06,
          loop: false),
      CTRPlayerAnimState.idle2: SpriteAnimation.spriteList(
          _sprites.sublist(53, 61),
          stepTime: 0.06,
          loop: false),
    };
    _animationComponent = SpriteAnimationGroupComponent(
        animations: animMap, current: CTRPlayerAnimState.reset);
    _animationComponent.size = charSize;
    _animationComponent.position =
        Vector2(_animationComponent.size.x * 0.5, _animationComponent.size.y);
    _animationComponent.anchor = Anchor.bottomCenter;
    _animationComponent
        .animationTickers?[CTRPlayerAnimState.idle1]?.onComplete = () {
      _animationComponent.animationTickers?[CTRPlayerAnimState.idle1]?.reset();
      _animationComponent.current = CTRPlayerAnimState.reset;
    };
    _animationComponent
        .animationTickers?[CTRPlayerAnimState.idle2]?.onComplete = () {
      _animationComponent.animationTickers?[CTRPlayerAnimState.idle2]?.reset();
      _animationComponent.current = CTRPlayerAnimState.reset;
    };

    add(_animationComponent);

    final charEffect = ScaleEffect.to(
        Vector2(1.1, 0.9),
        EffectController(
            duration: 0.6,
            reverseDuration: 0.3,
            infinite: true,
            curve: Curves.easeOutCubic));
    _animationComponent.add(charEffect);
    return super.onLoad();
  }

  eat() {
    _animationComponent.animationTickers?[CTRPlayerAnimState.eat]?.reset();
    _animationComponent.current = CTRPlayerAnimState.eat;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is CTRCandyCollisionComponent) {
      other.candy?.target?.beEaten();
      eat();
    }
  }

  @override
  update(double dt) {
    super.update(dt);
    _lastIdleAnimElapsedTime += dt;
    if (_lastIdleAnimElapsedTime > 8 &&
        _animationComponent.current == CTRPlayerAnimState.reset &&
        _animationComponent.current != CTRPlayerAnimState.eat) {
      _lastIdleAnimElapsedTime = 0;
      final states = [CTRPlayerAnimState.idle1, CTRPlayerAnimState.idle2];
      final state = states[Random().nextInt(states.length)];
      print("state: $state");
      _animationComponent.current = state;
    }
  }

  Future<List<Sprite>> _genSpriteSlices() async {
    List<Sprite> sprites = [];
    final List<Map<String, double>> rects = [
      {"x": 2, "y": 2, "M": 80.4, "U": 82.8},
      {"x": 2, "y": 87, "M": 80.4, "U": 82},
      {"x": 2, "y": 171, "M": 80.4, "U": 82.4},
      {"x": 2, "y": 256, "M": 80.4, "U": 82.8},
      {"x": 2, "y": 341, "M": 80.4, "U": 82.8},
      {"x": 2, "y": 426, "M": 80.4, "U": 84.4},
      {"x": 2, "y": 513, "M": 80.4, "U": 85.6},
      {"x": 2, "y": 601, "M": 80.4, "U": 87.2},
      {"x": 2, "y": 691, "M": 80.4, "U": 88},
      {"x": 2, "y": 781, "M": 80.4, "U": 88.8},
      {"x": 85, "y": 2, "M": 80.4, "U": 89.6},
      {"x": 85, "y": 94, "M": 80.4, "U": 89.6},
      {"x": 85, "y": 186, "M": 80.4, "U": 90},
      {"x": 85, "y": 278, "M": 80.4, "U": 90.4},
      {"x": 85, "y": 371, "M": 80.4, "U": 90.4},
      {"x": 85, "y": 464, "M": 80.4, "U": 88.4},
      {"x": 85, "y": 555, "M": 80.4, "U": 86.8},
      {"x": 85, "y": 644, "M": 80.4, "U": 85.2},
      {"x": 85, "y": 732, "M": 80.4, "U": 84},
      {"x": 85, "y": 818, "M": 81.6, "U": 90},
      {"x": 169, "y": 2, "M": 81.2, "U": 85.2},
      {"x": 169, "y": 90, "M": 80.4, "U": 84},
      {"x": 169, "y": 176, "M": 80.4, "U": 82.8},
      {"x": 169, "y": 261, "M": 80.4, "U": 81.2},
      {"x": 169, "y": 345, "M": 80.4, "U": 80},
      {"x": 169, "y": 427, "M": 80.4, "U": 80},
      {"x": 169, "y": 509, "M": 80.4, "U": 80},
      {"x": 169, "y": 591, "M": 80.4, "U": 80},
      {"x": 169, "y": 673, "M": 80.4, "U": 83.2},
      {"x": 169, "y": 759, "M": 80.4, "U": 86.4},
      {"x": 253, "y": 2, "M": 81.6, "U": 77.2},
      {"x": 253, "y": 82, "M": 88.4, "U": 68.4},
      {"x": 253, "y": 153, "M": 99.6, "U": 78.4},
      {"x": 253, "y": 234, "M": 90, "U": 78.8},
      {"x": 253, "y": 315, "M": 82, "U": 81.6},
      {"x": 253, "y": 399, "M": 80.4, "U": 86.4},
      {"x": 253, "y": 488, "M": 80.8, "U": 88.8},
      {"x": 253, "y": 579, "M": 80.8, "U": 90},
      {"x": 253, "y": 671, "M": 82, "U": 89.6},
      {"x": 253, "y": 763, "M": 89.2, "U": 85.2},
      {"x": 355, "y": 2, "M": 96.8, "U": 81.2},
      {"x": 355, "y": 86, "M": 61.2, "U": 34.4},
      {"x": 355, "y": 123, "M": 56, "U": 35.6},
      {"x": 355, "y": 161, "M": 87.2, "U": 80.4},
      {"x": 355, "y": 244, "M": 84.4, "U": 82},
      {"x": 355, "y": 328, "M": 82, "U": 84},
      {"x": 355, "y": 414, "M": 84.4, "U": 85.6},
      {"x": 355, "y": 502, "M": 85.6, "U": 86.8},
      {"x": 355, "y": 591, "M": 88, "U": 89.2},
      {"x": 355, "y": 683, "M": 89.6, "U": 86.4},
      {"x": 454, "y": 2, "M": 87.6, "U": 84.8},
      {"x": 454, "y": 89, "M": 78, "U": 82.4},
      {"x": 454, "y": 174, "M": 78, "U": 82.8},
      {"x": 454, "y": 259, "M": 78, "U": 84.4},
      {"x": 454, "y": 346, "M": 86.8, "U": 85.6},
      {"x": 454, "y": 434, "M": 90, "U": 86},
      {"x": 454, "y": 522, "M": 87.6, "U": 86},
      {"x": 454, "y": 610, "M": 78, "U": 86},
      {"x": 454, "y": 698, "M": 78, "U": 86},
      {"x": 454, "y": 786, "M": 78, "U": 86},
      {"x": 546, "y": 2, "M": 86.8, "U": 86},
      {"x": 546, "y": 90, "M": 90, "U": 86},
      {"x": 546, "y": 178, "M": 89.6, "U": 87.6},
      {"x": 546, "y": 268, "M": 87.6, "U": 88.8},
      {"x": 546, "y": 359, "M": 86, "U": 90},
      {"x": 546, "y": 451, "M": 86, "U": 86.8},
      {"x": 546, "y": 540, "M": 84, "U": 82},
      {"x": 546, "y": 624, "M": 87.2, "U": 80.4},
      {"x": 546, "y": 707, "M": 82.4, "U": 77.2},
      {"x": 546, "y": 787, "M": 80.4, "U": 78},
      {"x": 638, "y": 2, "M": 80.4, "U": 82.4},
      {"x": 638, "y": 87, "M": 81.6, "U": 84.8},
      {"x": 638, "y": 174, "M": 82.4, "U": 85.6},
      {"x": 638, "y": 262, "M": 83.2, "U": 86},
      {"x": 638, "y": 350, "M": 83.2, "U": 86.4},
      {"x": 638, "y": 439, "M": 82.4, "U": 82},
      {"x": 638, "y": 523, "M": 82.4, "U": 76.4},
      {"x": 638, "y": 602, "M": 81.6, "U": 77.6},
      {"x": 638, "y": 682, "M": 80.8, "U": 82.4},
      {"x": 638, "y": 767, "M": 80.8, "U": 85.6},
      {"x": 724, "y": 2, "M": 81.2, "U": 86.8},
      {"x": 724, "y": 91, "M": 81.6, "U": 86.4},
      {"x": 724, "y": 180, "M": 81.6, "U": 84.8},
      {"x": 724, "y": 267, "M": 81.6, "U": 81.6}
    ];
    final List<Offset> offsets = spriteOffsets();
    for (int i = 0; i < rects.length; ++i) {
      final rect = rects[i];
      final pos = Vector2(rect["x"]!, rect["y"]!);
      final size = Vector2(rect["M"]!, rect["U"]!);
      final sprite = await Sprite.load("char_animations.png",
          srcPosition: pos, srcSize: size, images: images);
      final offset = offsets[i];
      final composition = ImageComposition()
        ..add(await sprite.toImage(), Vector2(offset.dx, offset.dy));
      final composeImage = await composition.compose();
      sprites.add(Sprite(composeImage));
    }
    return sprites;
  }

  List<Offset> spriteOffsets() {
    final List<Map<String, double>> raw = [
      {"x": 88, "y": 90.8},
      {"x": 88, "y": 91.2},
      {"x": 88, "y": 91.2},
      {"x": 88, "y": 90.8},
      {"x": 88, "y": 90.8},
      {"x": 88, "y": 89.2},
      {"x": 88, "y": 88},
      {"x": 88, "y": 86.4},
      {"x": 88, "y": 85.6},
      {"x": 88, "y": 84.8},
      {"x": 88, "y": 84},
      {"x": 88, "y": 84},
      {"x": 88, "y": 83.6},
      {"x": 88, "y": 83.2},
      {"x": 88, "y": 83.2},
      {"x": 88, "y": 85.2},
      {"x": 88, "y": 86.8},
      {"x": 88, "y": 88.4},
      {"x": 88, "y": 89.6},
      {"x": 86.8, "y": 83.6},
      {"x": 87.2, "y": 88.4},
      {"x": 87.6, "y": 89.6},
      {"x": 87.6, "y": 90.8},
      {"x": 87.6, "y": 92.4},
      {"x": 87.6, "y": 93.6},
      {"x": 87.6, "y": 93.6},
      {"x": 87.6, "y": 93.6},
      {"x": 87.6, "y": 93.6},
      {"x": 87.6, "y": 90.4},
      {"x": 87.6, "y": 87.2},
      {"x": 87.2, "y": 96.4},
      {"x": 84, "y": 105.2},
      {"x": 76.4, "y": 95.2},
      {"x": 81.2, "y": 94.8},
      {"x": 86.4, "y": 92},
      {"x": 88, "y": 87.2},
      {"x": 87.6, "y": 84.8},
      {"x": 87.6, "y": 83.6},
      {"x": 86.4, "y": 84},
      {"x": 81.6, "y": 88.4},
      {"x": 78, "y": 92.4},
      {"x": 96, "y": 105.6},
      {"x": 99.6, "y": 106},
      {"x": 84, "y": 92.8},
      {"x": 86.4, "y": 91.2},
      {"x": 87.2, "y": 89.2},
      {"x": 84.4, "y": 88},
      {"x": 83.2, "y": 86.4},
      {"x": 81.6, "y": 84.4},
      {"x": 80.4, "y": 87.2},
      {"x": 82.8, "y": 88.8},
      {"x": 92.4, "y": 91.2},
      {"x": 92.4, "y": 90.8},
      {"x": 92.4, "y": 89.2},
      {"x": 83.6, "y": 88},
      {"x": 80.4, "y": 87.6},
      {"x": 82.8, "y": 87.6},
      {"x": 92.4, "y": 87.6},
      {"x": 92.4, "y": 87.6},
      {"x": 92.4, "y": 87.6},
      {"x": 83.6, "y": 87.6},
      {"x": 80.4, "y": 87.6},
      {"x": 80.4, "y": 86},
      {"x": 81.6, "y": 84.8},
      {"x": 82.8, "y": 83.6},
      {"x": 83.2, "y": 86.8},
      {"x": 86.4, "y": 91.2},
      {"x": 84, "y": 92.8},
      {"x": 86, "y": 96},
      {"x": 88, "y": 95.2},
      {"x": 88, "y": 90.8},
      {"x": 86.8, "y": 88.4},
      {"x": 86, "y": 87.6},
      {"x": 85.2, "y": 87.2},
      {"x": 85.2, "y": 86.8},
      {"x": 86, "y": 91.2},
      {"x": 86, "y": 96.8},
      {"x": 86.8, "y": 95.6},
      {"x": 87.6, "y": 90.4},
      {"x": 88, "y": 87.2},
      {"x": 88, "y": 86},
      {"x": 88, "y": 86.4},
      {"x": 87.6, "y": 88},
      {"x": 87.2, "y": 91.6}
    ];
    List<Offset> offsets = [];
    for (final pos in raw) {
      offsets.add(Offset(pos["x"]! - 76, pos["y"]! - 83));
    }
    return offsets;
  }
}
