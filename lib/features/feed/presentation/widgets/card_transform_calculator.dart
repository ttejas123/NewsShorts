import 'dart:ui';

class CardTransform {
  final Offset translate;
  final double opacity;

  const CardTransform({required this.translate, required this.opacity});
}

class CardTransformCalculator {
  final double cardHeight;

  const CardTransformCalculator({required this.cardHeight});

  int getCurrentIndex(double offset) {
    return (offset / cardHeight).round();
  }

  double getProgress(double offset) {
    final base = getCurrentIndex(offset) * cardHeight;
    return ((offset - base) / cardHeight).clamp(0.0, 1.0);
  }

  CardTransform getTransformForCard({
    required int cardIndex,
    required double scrollOffset,
  }) {
    final current = getCurrentIndex(scrollOffset);
    final progress = getProgress(scrollOffset);
    final position = cardIndex - current;

    // 🔥 CURRENT CARD — ONLY ONE THAT MOVES
    if (position == 0) {
      return CardTransform(
        translate: Offset(0, -cardHeight * 0.85 * progress),
        opacity: 1.0 - progress,
      );
    }

    // 🔒 NEXT CARD — FIXED BEHIND
    if (position == 1) {
      return const CardTransform(translate: Offset.zero, opacity: 1.0);
    }

    // Everything else invisible
    return const CardTransform(translate: Offset.zero, opacity: 0.0);
  }

  bool isVisible(double offset, int index) {
    final current = getCurrentIndex(offset);
    return index == current || index == current + 1;
  }
}
