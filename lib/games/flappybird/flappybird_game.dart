import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

class FlappyBirdGame extends FlameGame {
  final images = Images(prefix: "assets/flappybird/sprites/");

  @override
  FutureOr<void> onLoad() async {
    setupBg();

    //

    return super.onLoad();
  }

  setupBg() async {
    final bgComponent = await loadParallaxComponent(
        [ParallaxImageData("background-day.png")],
        baseVelocity: Vector2(20, 0), images: images);
    add(bgComponent);
  }

  var _birdYVelocity = 0.0;
  var _gravity = 0.0;
  late PositionComponent _birdComponent;
  setupBird() async {
    // _birdComponent = SpriteAnimationComponent.fromFrameData(image, data);
  }

  updateBird(double dt) {}

  @override
  void update(double dt) {
    super.update(dt);
    updateBird(dt);
  }
}
