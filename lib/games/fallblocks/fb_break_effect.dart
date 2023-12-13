import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class FBBreakEffect extends PositionComponent {
  final Images? images;
  Sprite? _sprite;

  FBBreakEffect({super.position, super.size, this.images});

  @override
  FutureOr<void> onLoad() async {
    _sprite = await Sprite.load("block_dirt.webp", srcSize: Vector2(40, 40), images: images);

    final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
            count: 200,
            lifespan: 6,
            generator: (i) {
              final x = Random().nextDouble() * super.size.x;
              final y = Random().nextDouble() * super.size.y;
              final size = (Random().nextDouble() * 8 + 2);
              const colors = [
              ui.Color.fromARGB(255, 207, 59, 17),
              ui.Color.fromARGB(255, 229, 139, 52),
              ui.Color.fromARGB(255, 83, 33, 14),
              ];
              final color = colors[Random().nextInt(colors.length)];
              return AcceleratedParticle(
                  child: CircleParticle(paint: Paint()..color=color..style=PaintingStyle.fill, radius: size),
                  // SpriteParticle(sprite: _sprite!, size: Vector2(size, size)),
                  acceleration: Vector2(0, 700),
                  speed: Vector2((Random().nextDouble() * 100 - 50), (Random().nextDouble() * -100 - 200)),
                  position: Vector2(x, y));
            }));
    add(particleComponent);
    return super.onLoad();
  }

  @override
  void onMount() async {
    super.onMount();
    Future.delayed(const Duration(milliseconds: 6000)).then((value) {
      removeFromParent();
    });
  }
}
