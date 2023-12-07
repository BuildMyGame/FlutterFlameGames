import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_flame_games/games/cuttherope/ctr_rope.dart';

class CTRScissors extends BodyComponent with ContactCallbacks {
  bool valid = true;

  CTRScissors() {
    renderBody = false;
  }

  updatePosition(Vector2 newPos) {
    body.setTransform(newPos, 0);
  }

  @override
  Body createBody() {
    const bodySize = 20.0;
    final bodyDef = BodyDef(
        type: BodyType.dynamic,
        gravityOverride: Vector2(0, 0),
        userData: this,
        bullet: true,
        position: Vector2(0, 0));
    return world.createBody(bodyDef)
      ..createFixtureFromShape(CircleShape()..radius = bodySize * 0.5,
          density: 1, friction: 0.2, restitution: 0.5);
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is CTRRopeSegment) {
      if (valid && !other.isBreak) {
        other.removeFromParent();
        other.isBreak = true;
      }
    }
  }
}
