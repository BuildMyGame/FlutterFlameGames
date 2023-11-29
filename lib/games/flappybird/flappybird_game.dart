import 'dart:async';
import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/foundation.dart';

class FlappyBirdGame extends FlameGame with TapDetector {
  final images = Images(prefix: "assets/flappybird/sprites/");

  @override
  FutureOr<void> onLoad() async {
    await setupBg();
    await setupBird();

    return super.onLoad();
  }

  setupBg() async {
    final bgComponent = await loadParallaxComponent(
        [ParallaxImageData("background-day.png")],
        baseVelocity: Vector2(20, 0), images: images);
    add(bgComponent);
  }


  // bird
  var _birdYVelocity = 0.0;
  var _gravity = 150.0;
  late PositionComponent _birdComponent;
  setupBird() async {
    List<Sprite> redBirdSprites = [
      await Sprite.load("redbird-downflap.png", images: images),
      await Sprite.load("redbird-midflap.png", images: images),
      await Sprite.load("redbird-upflap.png", images: images)
    ];
    final anim = SpriteAnimation.spriteList(redBirdSprites, stepTime: 0.2);
    _birdComponent = SpriteAnimationComponent(animation: anim);
    resetBird();
    add(_birdComponent);
  }

  resetBird() {
    _birdComponent.position = Vector2(size.x * 0.3, size.y * 0.5);
    _birdYVelocity = 0.0;
  }

  updateBird(double dt) {
    _birdYVelocity += dt * _gravity;
    
    final birdNewY = _birdComponent.position.y + _birdYVelocity * dt;
    _birdComponent.position = Vector2(_birdComponent.position.x, birdNewY);
    _birdComponent.anchor = Anchor.center;
    final angle = clampDouble(_birdYVelocity / 180, -pi * 0.25, pi * 0.25) ;
    _birdComponent.angle = angle;

    if (birdNewY > size.y) {
      gameOver();
    }
  }


  // pipe

  gameOver() {
    resetBird();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateBird(dt);
  }

  @override
  void onTap() {
    super.onTap();
    _birdYVelocity = -100;
  }
}
