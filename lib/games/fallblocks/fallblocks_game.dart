import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/fallblocks/fb_block.dart';
import 'package:flutter_flame_games/games/fallblocks/fb_break_effect.dart';

class FallBlocksGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final mapSize = const Size(7, 12);
  final unitSize = const Size(40, 40);
  var gameBottomLineOrigin = Vector2(0, 0);

  late PositionComponent _gamePanelComponent;
  List<FBBlock> _blocks = [];

  @override
  FutureOr<void> onLoad() {
    // bg & panel
    final bgComponent = RectangleComponent(position: Vector2(0, 0), size: size)
      ..setColor(Colors.blueGrey);
    add(bgComponent);

    final gamePanelSize = Vector2(
        unitSize.width * mapSize.width, unitSize.height * mapSize.height);
    final gamePanelClipComponent =
        ClipComponent.rectangle(position: size * 0.5, size: gamePanelSize)
          ..anchor = Anchor.center;
    add(gamePanelClipComponent);
    _gamePanelComponent = RectangleComponent(size: gamePanelSize)
      ..setColor(Colors.blue);

    gamePanelClipComponent.add(_gamePanelComponent);

    gameBottomLineOrigin = Vector2(0, gamePanelSize.y - unitSize.height);

    nextTurn();

    return super.onLoad();
  }

  nextTurn() async {
    print("Next turn");
    newLine();
    await Future.delayed(const Duration(milliseconds: 300));
    await checkFall();
    while (await checkLine()) {
      await Future.delayed(const Duration(milliseconds: 100));
      await checkFall();
    }
    if (_blocks.length < 3) {
      newLine();
    }
  }

  checkFall() async {
    // make all blocks fall
    while (true) {
      bool hasAnyFallBlock = false;
      for (final block in _blocks) {
        hasAnyFallBlock |= block.fallToBlock();
      }
      if (!hasAnyFallBlock) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 300));

      print("check fall eposion");
    }
    print("check fall finish");
  }

  Future<bool> checkLine() async {
    Map<int, List<FBBlock>> blockStats = {};
    Map<int, double> blockWidthStats = {};
    for (final block in _blocks) {
      int row = (block.position.y - unitSize.height * 0.5) ~/ unitSize.height;
      if (!blockStats.containsKey(row)) {
        blockStats[row] = [];
        blockWidthStats[row] = 0;
      }
      blockStats[row]!.add(block);
      blockWidthStats[row] = blockWidthStats[row]! + block.size.x;
    }
    bool anyRemove = false;
    for (final key in blockStats.keys) {
      if (blockWidthStats[key]! >
          (_gamePanelComponent.width - unitSize.width * 0.5)) {
        _blocks.removeWhere((element) {
          bool needRemove = blockStats[key]?.contains(element) ?? false;
          if (needRemove) {
            element.removeFromParent();
          }
          return needRemove;
        });
        final effectPos = Vector2(_gamePanelComponent.l, (key + 1) * unitSize.height);
        add(FBBreakEffect(
            position: effectPos,
            size: Vector2(_gamePanelComponent.width, unitSize.height)));
        anyRemove = true;
      }
    }
    return anyRemove;
  }

  newLine() {
    // lift old blocks
    for (final block in _blocks) {
      block.liftOneUnit();
    }

    // create new line
    final unitCountOptions = [1, 2, 3];
    List<int> blocksUnitCount = [];
    var leftUnitCount = mapSize.width.toInt();
    while (true) {
      final unitCount = min(leftUnitCount,
          unitCountOptions[Random().nextInt(unitCountOptions.length)]);
      blocksUnitCount.add(unitCount);
      leftUnitCount -= unitCount;
      if (leftUnitCount == 0) {
        break;
      }
    }

    var gapIndex = Random().nextInt(blocksUnitCount.length);
    // create blocks
    var pos = 0;
    var lineOrigin = gameBottomLineOrigin;
    for (int i = 0; i < blocksUnitCount.length; ++i) {
      final unitCount = blocksUnitCount[i];
      if (i != gapIndex) {
        final block = FBBlock(
            unitSize: unitSize,
            unitCount: unitCount,
            xLimit: Offset(0, _gamePanelComponent.size.x),
            yLimit: Offset(0, _gamePanelComponent.size.y))
          ..position = Vector2(lineOrigin.x + pos * unitSize.width,
              lineOrigin.y + unitSize.height);
        _gamePanelComponent.add(block);
        block.liftOneUnit();
        _blocks.add(block);
      }
      pos += unitCount;
    }
  }
}
