import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_star.dart';

class CTRCandyCollisionComponent extends PositionComponent
    with CollisionCallbacks {
  final WeakReference<CTRCandy>? candy;
  CTRCandyCollisionComponent({this.candy});
  
  @override
  FutureOr<void> onLoad() {
    size = Vector2(40, 40);

    add(CircleHitbox(radius: 30)
      ..anchor = Anchor.center
      ..position = Vector2(0, 0));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is CTRStar) {
      other.disappear();
    }
  }
}

class CTRCandy extends BodyComponent {
  final Images? images;
  final Offset pos;

  late SpriteComponent _candyBgComponent;
  late SpriteComponent _candyFgComponent;
  late CTRCandyCollisionComponent collisionComponent;
  CTRCandy({this.images, this.pos = const Offset(0, 0)});

  @override
  Future<void> onLoad() async {
    renderBody = false;
    final candyBg = await Sprite.load("obj_candy_01.png",
        images: images, srcPosition: Vector2(2, 2), srcSize: Vector2(87, 90));
    _candyBgComponent = SpriteComponent(sprite: candyBg)
      ..anchor = Anchor.center
      ..position = Vector2(6, 13);
    add(_candyBgComponent);

    final candyFg = await Sprite.load("obj_candy_01.png",
        images: images, srcPosition: Vector2(2, 95), srcSize: Vector2(60, 60));
    _candyFgComponent = SpriteComponent(sprite: candyFg)
      ..anchor = Anchor.center
      ..position = Vector2(0, 0);
    add(_candyFgComponent);

    collisionComponent = CTRCandyCollisionComponent(candy: WeakReference(this));
    parent?.add(collisionComponent);

    return super.onLoad();
  }

  @override
  Body createBody() {
    const bodySize = 70.0;
    final bodyDef = BodyDef(
        type: BodyType.dynamic,
        userData: this,
        position: Vector2(this.pos.dx, this.pos.dy));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(CircleShape()..radius = bodySize * 0.5,
          density: 1, friction: 0.2, restitution: 0.5);
  }

  beEaten() {
    _candyBgComponent.add(OpacityEffect.fadeOut(EffectController(duration: 0.3))
      ..removeOnFinish = false);
    _candyFgComponent.add(OpacityEffect.fadeOut(EffectController(duration: 0.3))
      ..removeOnFinish = false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    collisionComponent.position = body.position;
  }

  //[{"x":2,"y":2,"M":87.2,"U":90.4},{"x":2,"y":95,"M":60.4,"U":60.4},{"x":2,"y":158,"M":62.8,"U":63.2},{"x":2,"y":224,"M":39.2,"U":24.8},{"x":2,"y":251,"M":19.2,"U":18},{"x":2,"y":271,"M":19.6,"U":23.6},{"x":92,"y":2,"M":22,"U":22.8},{"x":92,"y":27,"M":21.2,"U":25.2},{"x":92,"y":55,"M":58.4,"U":58.8},{"x":92,"y":116,"M":61.2,"U":65.2},{"x":92,"y":184,"M":61.2,"U":66.4},{"x":92,"y":253,"M":62.4,"U":67.6},{"x":157,"y":2,"M":65.2,"U":70},{"x":157,"y":74,"M":63.6,"U":70},{"x":157,"y":146,"M":63.6,"U":63.6},{"x":157,"y":212,"M":60,"U":60},{"x":157,"y":274,"M":57.6,"U":60},{"x":157,"y":336,"M":55.2,"U":58.4},{"x":225,"y":2,"M":120.8,"U":121.2},{"x":225,"y":126,"M":42.8,"U":63.2},{"x":225,"y":192,"M":38.4,"U":62.8},{"x":225,"y":257,"M":100.8,"U":107.2},{"x":225,"y":367,"M":111.2,"U":122},{"x":225,"y":491,"M":148.4,"U":158.8},{"x":376,"y":2,"M":154,"U":158.4},{"x":376,"y":163,"M":150.8,"U":154.4}]
}
