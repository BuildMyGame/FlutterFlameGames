import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_games/games/fallblocks/fb_background_component.dart';
import 'package:flutter_flame_games/games/fallblocks/fb_block.dart';
import 'package:flutter_flame_games/games/fallblocks/fb_break_effect.dart';

class FallBlocksGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  final images = Images(prefix: "assets/fallblocks/sprites/");
  final mapSize = const Size(8, 15);
  var unitSize = const Size(40, 40);
  var gameBottomLineOrigin = Vector2(0, 0);

  late PositionComponent _gamePanelComponent;
  final List<FBBlock> _blocks = [];
  var score = 0;
  var _lastCheckLineDelta = 0.0;
  var _shouldCheckLine = false;

  @override
  FutureOr<void> onLoad() async {
    // bg & panel
    final bgImage = await images.load("background.png");
    final bgComponent = FBBackgroundComponnet(
        size: size,
        image: bgImage);
    add(bgComponent);

    // caculate the fit unit size
    const gameAreaPadding = 40.0;
    final maxUnitSizeW = (size.x - gameAreaPadding * 2.0) / mapSize.width;
    final maxUnitSizeH = (size.y - gameAreaPadding * 2.0) / mapSize.height;
    final finalUnitSize = min(maxUnitSizeW, maxUnitSizeH);
    unitSize = Size(finalUnitSize, finalUnitSize);

    final gamePanelSize = Vector2(
        unitSize.width * mapSize.width, unitSize.height * mapSize.height);
    final gamePanelClipComponent =
        ClipComponent.rectangle(position: size * 0.5, size: gamePanelSize)
          ..anchor = Anchor.center;
    add(gamePanelClipComponent);
    _gamePanelComponent = RectangleComponent(size: gamePanelSize)
      ..setColor(Colors.black.withAlpha(220));

    gamePanelClipComponent.add(_gamePanelComponent);

    await setupScoreLabel();

    gameBottomLineOrigin = Vector2(0, gamePanelSize.y - unitSize.height);

    nextTurn();

    return super.onLoad();
  }

  @override
  update(double dt) async {
    super.update(dt);
    updateScoreLabel();

    _lastCheckLineDelta += dt;
    if (_lastCheckLineDelta > 0.2 && _shouldCheckLine) {
      _lastCheckLineDelta = 0;
      bool isAllGrounded = true;
      for (final block in _blocks) {
        isAllGrounded &= block.isGrounded();
      }
      if (isAllGrounded) {
        bool res = checkLine();
        if (res) {
          _shouldCheckLine = true;
          for (final block in _blocks.reversed) {
            block.markNeedFall();
          }
          if (_blocks.isEmpty) {
            newLine();
          }
        } else {
          _shouldCheckLine = false;
          checkFail();
        }
      }
    }
  }

  nextTurn() async {
    newLine();
    await Future.delayed(const Duration(milliseconds: 100));
    for (final block in _blocks.reversed) {
      block.markNeedFall();
    }
    _shouldCheckLine = true;
  }

  bool checkLine() {
    Map<int, List<FBBlock>> blockStats = {};
    Map<int, double> blockWidthStats = {};
    for (final block in _blocks) {
      if (block.position.y < 0) {
        continue;
      }
      int row = (block.position.y + unitSize.height * 0.5) ~/ unitSize.height;
      
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
        final effectPos = Vector2(_gamePanelComponent.absolutePosition.x,
            _gamePanelComponent.absolutePosition.y + key * unitSize.height);
        add(FBBreakEffect(
            images: images,
            position: effectPos,
            size: Vector2(_gamePanelComponent.width, unitSize.height)));
        score++;
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
    final unitCountOptions = [1, 2, 3, 4];
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
            images: images,
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

  void checkFail() {
    for (final block in _blocks) {
      int row = (block.position.y - unitSize.height * 0.5) ~/ unitSize.height;
      if (row < 0) {
        overlays.add("failed");
        return;
      }
    }
  }

  void reset() {
    for (final block in _blocks) {
      block.removeFromParent();
    }
    _blocks.clear();
    score = 0;
    updateScoreLabel();
    nextTurn();
  }

  // scoreLabel
  List<ui.Image> _numSprites = [];
  late SpriteComponent scoreComponent;
  setupScoreLabel() async {
    for (int i = 0; i < 10; ++i) {
      final imgName = "$i.png";
      _numSprites.add(await images.load(imgName));
    }

    scoreComponent = SpriteComponent()
      ..position = Vector2(size.x * 0.5, 100)
      ..sprite = Sprite(_numSprites[0]);
    scoreComponent.anchor = Anchor.center;
    add(scoreComponent);
  }

  updateScoreLabel() async {
    final scoreStr = score.toString();
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
    scoreComponent.sprite = Sprite(img);
  }
}
