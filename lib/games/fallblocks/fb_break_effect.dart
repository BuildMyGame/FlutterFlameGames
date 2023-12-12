import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class FBBreakEffect extends PositionComponent {
  FBBreakEffect({super.position, super.size});

  @override
  FutureOr<void> onLoad() async {
    final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
            count: 100,
            lifespan: 6,
            generator: (i) {
              final x = Random().nextDouble() * super.size.x;
              final y = Random().nextDouble() * super.size.y;
              return AcceleratedParticle(
                  child: CircleParticle(
                      radius: Random().nextDouble() * 5 + 2,
                      paint: Paint()..color = Colors.amber),
                  acceleration: Vector2(0, 700),
                  speed: Vector2((Random().nextDouble() * 100 - 50), -200),
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
