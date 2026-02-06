import 'dart:math';
import 'package:flutter/widgets.dart';

class StackedSnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const StackedSnapScrollPhysics({
    required this.itemExtent,
    super.parent = const BouncingScrollPhysics(),
  });

  @override
  StackedSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return StackedSnapScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final page = position.pixels / itemExtent;

    if (velocity.abs() < tolerance.velocity) {
      return (page.roundToDouble() * itemExtent).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
    }

    final targetPage = velocity > 0 ? page.ceil() : page.floor();

    return (targetPage * itemExtent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = this.tolerance;

    if ((velocity.abs() < tolerance.velocity) &&
        (position.pixels - position.minScrollExtent).abs() <
            tolerance.distance) {
      return null;
    }

    final target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    return super.createBallisticSimulation(position, velocity);
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 0.9, stiffness: 180, damping: 22);
}
