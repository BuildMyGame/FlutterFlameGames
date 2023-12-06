import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class CandyObj extends BodyComponent {
  double size;
  Offset pos;

  CandyObj({this.size = 20, this.pos = const Offset(0, 20)}) {
    print("pos: $pos");
    add(CircleComponent(radius: size * 0.5)
      ..setColor(Colors.amber)
      ..position = Vector2(-size * 0.5, -size * 0.5));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
        type: BodyType.dynamic,
        userData: this,
        position: Vector2(this.pos.dx, this.pos.dy));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(CircleShape()..radius = size * 0.5,
          density: 10, friction: 0.2, restitution: 0.5);
  }
}

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
  final Offset pos;
  late Vector2 _size;

  CTRRopeSegment({this.pos = const Offset(0, 0)}) {
    _size = Vector2(5, 5);
    // renderBody = false;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
        type: BodyType.dynamic,
        userData: this,
        position: Vector2(pos.dx, pos.dy));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(
          PolygonShape()
            ..setAsBox(_size.x * 0.5, _size.y * 0.5,
                Vector2(_size.x * 0.5, _size.y * 0.5), 0),
          density: 10,
          friction: 0,
          restitution: 0);
  }

  // @override
  // void renderPolygon(Canvas canvas, List<Offset> points) {
  //   canvas.drawPoints(
  //       PointMode.polygon,
  //       points,
  //       Paint()
  //         ..color = Colors.amber
  //         ..style = PaintingStyle.fill);
  //   // super.renderPolygon(canvas, points);
  // }
}

class CTRRope<T extends Forge2DGame> extends PositionComponent
    with HasGameReference<T>, TapCallbacks {
  final Offset startPosition;
  final Offset endPosition;
  final double length;

  BodyComponent? endComponent;
  List<CTRRopeSegment> _ropSegs = [];
  CTRRope(
      {this.startPosition = const Offset(0, 0),
      this.endPosition = const Offset(0, 100),
      this.length = 100});

  @override
  FutureOr<void> onLoad() async {
    final pin = PinObj(pos: Offset(startPosition.dx, startPosition.dy));
    add(pin);
    await Future.wait([pin.loaded]);
    const ropeSegLen = 50.0;
    final ropeSegCount = length ~/ ropeSegLen;
    final deltaOffset = (endPosition - startPosition);
    final space = deltaOffset.distance / ropeSegCount;
    final dirVec = deltaOffset / deltaOffset.distance;
    CTRRopeSegment? lastRopeSeg;
    for (int i = 0; i < ropeSegCount; ++i) {
      final seg =
          CTRRopeSegment(pos: dirVec * i.toDouble() * space + startPosition);
      add(seg);
      await Future.wait([seg.loaded]);
      final jointDef = RopeJointDef()
        ..bodyA = lastRopeSeg?.body ?? pin.body
        ..bodyB = seg.body
        ..maxLength = ropeSegLen;
      game.world.createJoint(RopeJoint(jointDef));
      // final jointDef = DistanceJointDef()
      //   ..initialize(lastRopeSeg?.body ?? pin.body, seg.body,
      //       (lastRopeSeg?.body ?? pin.body).worldCenter, seg.body.worldCenter)
      //   ..frequencyHz = 3
      //   ..dampingRatio = 0.3
      //   ..length = ropeSegLen;
      // game.world.createJoint(DistanceJoint(jointDef));
      lastRopeSeg = seg;
      _ropSegs.add(seg);
    }

    final endPin = CandyObj(pos: Offset(endPosition.dx, endPosition.dy));
    add(endPin);
    await Future.wait([endPin.loaded]);
    final jointDef = RopeJointDef()
      ..bodyA = lastRopeSeg?.body ?? pin.body
      ..bodyB = endPin.body
      ..maxLength = ropeSegLen;
    game.world.createJoint(RopeJoint(jointDef));
    endComponent = endPin;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Vector2 lastPos = Vector2(startPosition.dx, startPosition.dy);
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Path ropePath = Path();
    ropePath.moveTo(startPosition.dx, startPosition.dy);
    for (int i = 0; i < _ropSegs.length; i++) {
      final currenPt = _ropSegs[i].position;
      final controlX = ((currenPt + lastPos) * 0.5).x;
      ropePath.cubicTo(controlX, lastPos.y, controlX, currenPt.y, currenPt.x, currenPt.y);
      lastPos = currenPt;
    }
    if (endComponent != null) {
      ropePath.quadraticBezierTo(lastPos.x, lastPos.y, endComponent!.position.x, endComponent!.position.y);
    }
    canvas.drawPath(ropePath, paint);
  }
}
