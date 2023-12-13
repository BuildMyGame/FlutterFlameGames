import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:smoothie/smoothie.dart';

class CTRRopePin extends BodyComponent {
  double size;
  Offset pos;

  CTRRopePin({this.size = 20, this.pos = const Offset(0, 20)}) {
    renderBody = false;
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
  bool isBreak = false;

  CTRRopeSegment({this.pos = const Offset(0, 0)}) {
    _size = Vector2(10, 10);
    renderBody = false;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
        type: BodyType.dynamic,
        userData: this,
        position: Vector2(pos.dx, pos.dy));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(CircleShape()..radius = _size.x * 0.5,
          density: 1, friction: 0, restitution: 0);
  }
}

class CTRRope<T extends Forge2DGame> extends PositionComponent
    with HasGameReference<T>, TapCallbacks {
  final Offset startPosition;
  final BodyComponent? attachComponent;
  final double length;

  final List<CTRRopeSegment> _ropSegs = [];
  CTRRope(
      {this.startPosition = const Offset(0, 0),
      this.length = 100,
      this.attachComponent});

  @override
  FutureOr<void> onLoad() async {
    Offset endPosition = startPosition + Offset(length, 0);
    if (attachComponent != null) {
      await Future.wait([attachComponent!.loaded]);
      endPosition = Offset(
          attachComponent?.position.x ?? 0, attachComponent?.position.y ?? 0);
    }
    final pin = CTRRopePin(pos: Offset(startPosition.dx, startPosition.dy));
    add(pin);
    await Future.wait([pin.loaded]);
    const ropeSegLen = 8.0;
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
      lastRopeSeg = seg;
      _ropSegs.add(seg);
    }

    if (attachComponent != null) {
      final jointDef = RopeJointDef()
        ..bodyA = lastRopeSeg?.body ?? pin.body
        ..bodyB = attachComponent!.body
        ..maxLength = ropeSegLen;
      game.world.createJoint(RopeJoint(jointDef));
    }
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    List<Offset> points = [];
    points.add(startPosition);
    final paint1 = Paint()
      ..color = const Color(0xff815c3c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final paint2 = Paint()
      ..color = const Color.fromARGB(255, 65, 44, 27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < _ropSegs.length; i++) {
      final currenPt = _ropSegs[i].position;
      if (_ropSegs[i].isBreak) {
        points.add(const Offset(-1, -1));
      } else {
        points.add(Offset(currenPt.x, currenPt.y));
      }
    }
    if (attachComponent != null) {
      points.add(
          Offset(attachComponent!.position.x, attachComponent!.position.y));
    }

    final newPoints = points;
    bool togglePaint = false;
    for (int i = 0; i < newPoints.length - 1; i++) {
      if (i % 4 == 0) {
        togglePaint = !togglePaint;
      }
      final paint = togglePaint ? paint1 : paint2;
      if ((newPoints[i + 1].dx < 0 && newPoints[i + 1].dy < 0) ||
          (newPoints[i].dx < 0 && newPoints[i].dy < 0)) {
        continue;
      }
      canvas.drawLine(Offset(newPoints[i].dx, newPoints[i].dy),
          Offset(newPoints[i + 1].dx, newPoints[i + 1].dy), paint);
    }
  }
}
