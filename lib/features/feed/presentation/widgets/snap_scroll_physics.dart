import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class SnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const SnapScrollPhysics({required this.itemExtent, ScrollPhysics? parent})
    : super(parent: parent);

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / itemExtent;
  }

  double _getPixels(double page) {
    return page * itemExtent;
  }

  double _getFlingPages(double velocity) {
    final v = velocity.abs();

    if (v < 1200) return 0; // snap back / nearest
    if (v < 2800) return 1; // normal swipe
    return 1.5; // hard fling (MAX)
  }

  double _getTargetPage(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = _getPage(position);
    final flingPages = _getFlingPages(velocity);

    if (velocity.abs() > tolerance.velocity) {
      page += velocity > 0 ? flingPages : -flingPages;
    }

    return page.roundToDouble();
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = this.tolerance;

    if ((velocity.abs() <= tolerance.velocity) &&
        (position.pixels - position.minScrollExtent).abs() <
            tolerance.distance) {
      return null;
    }

    final targetPage = _getTargetPage(position, tolerance, velocity);
    final targetPixels = _getPixels(
      targetPage.clamp(
        position.minScrollExtent / itemExtent,
        position.maxScrollExtent / itemExtent,
      ),
    );

    if (targetPixels == position.pixels) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: tolerance,
    );
  }
}
