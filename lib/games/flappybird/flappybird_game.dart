import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class BonusZone extends PositionComponent with CollisionCallbacks {
  BonusZone({super.size});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Player) {
      other.score++;
      removeFromParent();
      FlameAudio.play("point.wav");
      print("Bonus: ${other.score}");
    }
  }
}

class Player extends SpriteAnimationComponent with CollisionCallbacks {
  var isDead = false;
  var score = 0;

  Player({super.animation});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PipeComponent) {
      FlameAudio.play("hit.wav");
      isDead = true;
    }
  }
}

class PipeComponent extends PositionComponent with CollisionCallbacks {
  final bool isUpsideDown;
  final Images? images;
  PipeComponent({this.isUpsideDown = false, this.images, super.size});
  @override
  FutureOr<void> onLoad() async {
    final nineBox = NineTileBox(
        await Sprite.load("pipe-green.png", images: images))
      ..setGrid(leftWidth: 0, rightWidth: 0, topHeight: 50, bottomHeight: 10);
    final spriteCom = NineTileBoxComponent(nineTileBox: nineBox, size: size);
    if (isUpsideDown) {
      spriteCom.flipVerticallyAroundCenter();
    }
    spriteCom.anchor = Anchor.topLeft;

    add(spriteCom);

    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  final images = Images(prefix: "assets/flappybird/sprites/");
  var gameSpeed = 90.0;
  final pipeFullSize = Vector2(52.0, 620.0);
  late PositionComponent _pipeLayer;

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.updatePrefix("assets/flappybird/audios/");
    FlameAudio.bgm.play("wing.wav");

    await setupBg();
    await setupBird();
    await setupScoreLabel();

    resetGame();
    return super.onLoad();
  }

  @override
  void onDispose() {
    super.onDispose();
    FlameAudio.bgm.stop();
  }

  setupBg() async {
    final bgComponent = await loadParallaxComponent(
        [ParallaxImageData("background-day.png")],
        baseVelocity: Vector2(5, 0), images: images);
    add(bgComponent);

    _pipeLayer = PositionComponent();
    add(_pipeLayer);

    final bottomBgComponent = await loadParallaxComponent(
        [ParallaxImageData("base.png")],
        baseVelocity: Vector2(gameSpeed, 0),
        images: images,
        alignment: Alignment.bottomLeft,
        repeat: ImageRepeat.repeatX,
        fill: LayerFill.none);
    add(bottomBgComponent);
  }

  // bird
  var _birdYVelocity = 0.0;
  final _gravity = 250.0;
  late Player _birdComponent;
  setupBird() async {
    List<Sprite> redBirdSprites = [
      await Sprite.load("redbird-downflap.png", images: images),
      await Sprite.load("redbird-midflap.png", images: images),
      await Sprite.load("redbird-upflap.png", images: images)
    ];
    final anim = SpriteAnimation.spriteList(redBirdSprites, stepTime: 0.2);
    _birdComponent = Player(animation: anim);
    add(_birdComponent);
  }

  updateBird(double dt) {
    _birdYVelocity += dt * _gravity;

    final birdNewY = _birdComponent.position.y + _birdYVelocity * dt;
    _birdComponent.position = Vector2(_birdComponent.position.x, birdNewY);
    _birdComponent.anchor = Anchor.center;
    final angle = clampDouble(_birdYVelocity / 180, -pi * 0.25, pi * 0.25);
    _birdComponent.angle = angle;

    if (birdNewY > size.y) {
      gameOver();
    }
  }

  // scoreLabel
  List<ui.Image> _numSprites = [];
  late SpriteComponent _scoreComponent;
  setupScoreLabel() async {
    for (int i = 0; i < 10; ++i) {
      final imgName = "$i.png";
      _numSprites.add(await images.load(imgName));
    }

    _scoreComponent = SpriteComponent()
      ..position = Vector2(size.x * 0.5, 100)
      ..sprite = Sprite(_numSprites[0]);
    _scoreComponent.anchor = Anchor.center;
    add(_scoreComponent);
  }

  updateScoreLabel() async {
    final scoreStr = _birdComponent.score.toString();
    final numCount = scoreStr.length;
    double offset = 0;
    final imgComposition = ImageComposition();
    for (int i = 0; i < numCount; ++i) {
      int num = int.parse(scoreStr[i]);
      imgComposition.add(
          _numSprites[num], Vector2(offset, _numSprites[num].size.y));
      offset += _numSprites[num].size.x;
    }
    final img = await imgComposition.compose();
    _scoreComponent.sprite = Sprite(img);
  }

  // pipe
  final _pipes = [];
  final _bonusZones = [];
  createPipe() {
    const pipeSpace = 220.0;
    const minPipeHeight = 120.0;
    const gapHeight = 90.0;
    const baseHeight = 112.0;
    const gapMaxRandomRange = 300;
    var lastPipePos = _pipes.lastOrNull?.position.x ?? size.x - pipeSpace;
    lastPipePos += pipeSpace;

    final gapCenterPos = min(gapMaxRandomRange,
                size.y - minPipeHeight * 2 - baseHeight - gapHeight) *
            Random().nextDouble() +
        minPipeHeight +
        gapHeight * 0.5;

    PipeComponent topPipe =
        PipeComponent(images: images, isUpsideDown: true, size: pipeFullSize)
          ..position = Vector2(
              lastPipePos, (gapCenterPos - gapHeight * 0.5) - pipeFullSize.y);
    _pipeLayer.add(topPipe);
    _pipes.add(topPipe);

    PipeComponent bottomPipe =
        PipeComponent(images: images, isUpsideDown: false, size: pipeFullSize)
          ..size = pipeFullSize
          ..position = Vector2(lastPipePos, gapCenterPos + gapHeight * 0.5);
    _pipeLayer.add(bottomPipe);
    _pipes.add(bottomPipe);

    final bonusZone = BonusZone(size: Vector2(pipeFullSize.x, gapHeight))
      ..position = Vector2(lastPipePos, gapCenterPos - gapHeight * 0.5);
    add(bonusZone);
    _bonusZones.add(bonusZone);
  }

  updatePipes(double dt) {
    for (final pipe in _pipes) {
      pipe.position =
          Vector2(pipe.position.x - dt * gameSpeed, pipe.position.y);
    }
    for (final bonusZone in _bonusZones) {
      bonusZone.position =
          Vector2(bonusZone.position.x - dt * gameSpeed, bonusZone.position.y);
    }
    _pipes.removeWhere((element) {
      final remove = element.position.x < -100;
      if (remove) {
        element.removeFromParent();
      }
      return remove;
    });
    _bonusZones.removeWhere((element) {
      final remove = element.position.x < -100;
      if (remove) {
        element.removeFromParent();
      }
      return remove;
    });

    if ((_pipes.lastOrNull?.position.x ?? 0) < size.x) {
      createPipe();
    }
  }

  gameOver() {
    FlameAudio.play("die.wav");
    resetGame();
  }

  resetGame() {
    _birdComponent.isDead = false;
    _birdComponent.score = 0;
    _birdComponent.position = Vector2(size.x * 0.3, size.y * 0.5);
    _birdYVelocity = 0.0;
    for (var element in _pipes) {
      element.removeFromParent();
    }
    _pipes.clear();

    for (var element in _bonusZones) {
      element.removeFromParent();
    }
    _bonusZones.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateBird(dt);
    updatePipes(dt);
    updateScoreLabel();
    if (_birdComponent.isDead) {
      FlameAudio.play("die.wav");
      gameOver();
    }
  }

  @override
  void onTap() {
    super.onTap();
    FlameAudio.play("swoosh.wav");
    _birdYVelocity = -120;
  }
}
