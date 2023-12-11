import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/fallblocks/fallblocks_game.dart';

class FBBlock extends PositionComponent
    with DragCallbacks, HasGameReference<FallBlocksGame> {
  final Size unitSize;
  final int unitCount;
  final Offset xLimit;
  final Offset yLimit;

  late final RectangleHitbox _hitBox;
  var _showHint = false;

  FBBlock(
      {this.unitSize = const Size(40, 40),
      this.unitCount = 1,
      this.xLimit = const Offset(0, 0),
      this.yLimit = const Offset(0, 0)}) {
    size = Vector2(unitSize.width * unitCount, unitSize.height);
    _hitBox = RectangleHitbox(position: Vector2.zero(), size: size);
    add(_hitBox);
  }

  liftOneUnit() {
    final newPos = Vector2(position.x, position.y - unitSize.height);
    add(MoveEffect.to(newPos, EffectController(duration: 0.1), onComplete: () {
      position = newPos;
    }));
  }

  bool fallToBlock() {
    var nearestBlockY = 10000.0;
    FBBlock? nearestFallToBlock;
    for (int i = 0; i < unitCount; ++i) {
      final ray = Ray2(
          origin: absolutePosition +
              Vector2(i * unitSize.width + unitSize.width * 0.5,
                  unitSize.height * 0.5),
          direction: Vector2(0, 1));
      final fallToBlockHitBox =
          game.collisionDetection.raycast(ray, ignoreHitboxes: [_hitBox]);
      final fallToBlock = (fallToBlockHitBox?.hitbox?.parent as FBBlock?);
      if (fallToBlock != null &&
          fallToBlock.position.y < nearestBlockY) {
        nearestBlockY = fallToBlock.position.y;
        nearestFallToBlock = fallToBlock;
      }
    }

    if (nearestFallToBlock != null) {
      if (nearestFallToBlock.position.y - position.y < unitSize.height * 1.1) {
        return false;
      }
      final targetPos =
          Vector2(position.x, nearestFallToBlock.position.y - unitSize.height);
      add(MoveEffect.to(targetPos, EffectController(duration: 0.1),
          onComplete: () {
        position = targetPos;
      }));
      return true;
    } else if (position.y < (yLimit.dy - unitSize.height * 1.1)) {
      final targetPos = Vector2(position.x, yLimit.dy - unitSize.height);
      add(MoveEffect.to(targetPos, EffectController(duration: 0.1),
          onComplete: () {
        position = targetPos;
      }));

      return true;
    }

    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final width = unitSize.width * unitCount;
    final height = unitSize.height;
    const margin = 1.0;
    canvas.drawRRect(
        RRect.fromLTRBR(margin, margin, width - margin * 2.0,
            height - margin * 2.0, const Radius.circular(4.0)),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill);
  }

  // Drag Gesture
  Vector2 _dragBeginPosition = Vector2.zero();
  double _dragLimitLeft = 0;
  double _dragLimitRight = 0;
  RectangleComponent? _snapHitComponent;
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _snapHitComponent =
        RectangleComponent.fromRect(Rect.fromLTRB(0, 0, size.x, size.y))
          ..setColor(Colors.red.withAlpha(100));
    parent?.add(_snapHitComponent!);

    _dragBeginPosition = position;
    final leftRay =
        Ray2(origin: absolutePosition + size * 0.5, direction: Vector2(-1, 0));
    final leftHitBox =
        game.collisionDetection.raycast(leftRay, ignoreHitboxes: [_hitBox]);
    final leftComponent = (leftHitBox?.hitbox?.parent as FBBlock?);
    _dragLimitLeft = leftComponent == null
        ? xLimit.dx
        : leftComponent.position.x + leftComponent.size.x;

    final rightRay =
        Ray2(origin: absolutePosition + size * 0.5, direction: Vector2(1, 0));
    final rightHitBox =
        game.collisionDetection.raycast(rightRay, ignoreHitboxes: [_hitBox]);
    final rightComponent = (rightHitBox?.hitbox?.parent as FBBlock?);
    _dragLimitRight =
        (rightComponent == null ? xLimit.dy : rightComponent.position.x) -
            size.x;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    var newPos = _dragBeginPosition + Vector2(event.delta.x, 0);
    var newPosX = clampDouble(newPos.x, _dragLimitLeft, _dragLimitRight);
    position = Vector2(newPosX, position.y);

    final snapPos = _snapPosition();
    if (_snapHitComponent != null) {
      _snapHitComponent!.position = snapPos;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_snapHitComponent != null) {
      _snapHitComponent!.removeFromParent();
      _snapHitComponent = null;
    }

    final snapPos = _snapPosition();
    add(MoveEffect.to(snapPos, EffectController(duration: 0.1), onComplete: () {
      position = snapPos;
      game.nextTurn();
    }));
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_snapHitComponent != null) {
      _snapHitComponent!.removeFromParent();
      _snapHitComponent = null;
    }
  }

  Vector2 _snapPosition() {
    final snapPosX =
        (position.x / unitSize.width + 0.5).toInt() * unitSize.width;
    return Vector2(snapPosX, position.y);
  }
}
