import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class FBBackgroundComponnet extends PositionComponent {
  final ui.Image? image;
  FBBackgroundComponnet({this.image, super.size});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    double currentY = 0.0;
    while (currentY < size.y) {
      double currentX = 0.0;
      while (currentX < size.x) {
        if (image != null) {
          canvas.drawImage(image!, Offset(currentX, currentY), Paint());
          currentX += image!.width;
        }
      }
      currentY += image!.height;
    }
  }
}
