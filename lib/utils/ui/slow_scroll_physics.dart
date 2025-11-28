import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class SlowScrollPhysics extends ClampingScrollPhysics {
  final double speedFactor;

  const SlowScrollPhysics({this.speedFactor = 0.65, super.parent});

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(speedFactor: speedFactor, parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * speedFactor;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Simulation? sim = super.createBallisticSimulation(position, velocity * speedFactor);
    return sim;
  }
}