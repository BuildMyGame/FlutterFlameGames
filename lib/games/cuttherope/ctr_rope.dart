import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class PinObj extends BodyComponent {
  double size;
  Offset pos;

  PinObj({this.size = 20, this.pos = const Offset(0, 20)}) {
    print("pos: $pos");
    add(CircleComponent(radius: size * 0.5)
      ..setColor(Colors.amber)
      ..position = Vector2(-size * 0.5, -size * 0.5));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
        type: BodyType.static,
        userData: this,
        position: Vector2(this.pos.dx, this.pos.dy));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(CircleShape()..radius = size * 0.5,
          friction: 0.2, restitution: 0.5);
  }
}

class CTRRopeSegment extends BodyComponent {
  double length;
  late Vector2 _size;

  CTRRopeSegment({this.length = 10}) {
    _size = Vector2(5, length);
    // add(RectangleComponent(size: Vector2(5, length))
    // ..setColor(Colors.transparent));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
        type: BodyType.dynamic, userData: this, position: Vector2(0, 0));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(
          PolygonShape()
            ..setAsBox(_size.x * 0.5, _size.y * 0.5,
                Vector2(_size.x * 0.5, _size.y * 0.5), 0),
          density: 100,
          friction: 0,
          restitution: 0);
  }

  @override
  void renderPolygon(Canvas canvas, List<Offset> points) {
    canvas.drawPoints(
        PointMode.polygon,
        points,
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke);
    // super.renderPolygon(canvas, points);
  }
}

class CTRRope<T extends Forge2DGame> extends PositionComponent
    with HasGameReference<T> {
  final Vector2? startPosition;
  final double? length;
  CTRRope({this.startPosition, this.length});

  @override
  FutureOr<void> onLoad() async {
    final pin =
        PinObj(pos: Offset(startPosition?.x ?? 0.0, startPosition?.y ?? 0.0));
    add(pin);
    await Future.wait([pin.loaded]);
    CTRRopeSegment? lastRopeSeg;
    for (int i = 0; i < 20; ++i) {
      final b1 = CTRRopeSegment(length: 10);
      add(b1);
      await Future.wait([b1.loaded]);
      {
        final jointDef = RopeJointDef()
          ..bodyA = lastRopeSeg?.body ?? pin.body
          ..bodyB = b1.body
          ..maxLength = 15;
        game.world.createJoint(RopeJoint(jointDef));
      }
      lastRopeSeg = b1;
    }
    // {
    //   final jointDef = RevoluteJointDef()
    //     ..initialize(b1.body, b2.body, b1.body.position);
    //   game.world.createJoint(RevoluteJoint(jointDef));
    // }
    return super.onLoad();
  }
}
