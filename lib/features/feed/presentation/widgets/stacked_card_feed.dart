import 'package:flutter/material.dart';
import 'stacked_card_scroll_physics.dart';

typedef CardBuilder = Widget Function(BuildContext context, int index);
typedef OnCardIndexChanged = void Function(int index);

class StackedCardFeed extends StatefulWidget {
  final ScrollController controller;
  final int itemCount;
  final CardBuilder itemBuilder;
  final OnCardIndexChanged? onCardIndexChanged;

  const StackedCardFeed({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.onCardIndexChanged,
  });

  @override
  State<StackedCardFeed> createState() => _StackedCardFeedState();
}

class _StackedCardFeedState extends State<StackedCardFeed> {
  double _cardHeight = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_cardHeight == 0) return;

    final index = (widget.controller.offset / _cardHeight).round();

    if (index != _currentIndex) {
      _currentIndex = index;
      widget.onCardIndexChanged?.call(index);
      setState(() {}); // only when index changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _cardHeight = constraints.maxHeight;

        return Stack(
          children: [
            /// 🔹 SCROLL DRIVER (RECEIVES INPUT)
            ListView.builder(
              controller: widget.controller,
              physics: StackedSnapScrollPhysics(itemExtent: _cardHeight),
              itemCount: widget.itemCount,
              itemExtent: _cardHeight,
              itemBuilder: (_, __) => const SizedBox.expand(),
            ),

            /// 🔹 VISUAL STACK (INPUT PASSTHROUGH)
            GestureDetector(
              behavior: HitTestBehavior.translucent,

              onVerticalDragStart: (details) {
                var _dragStartOffset = widget.controller.offset;
              },

              onVerticalDragUpdate: (details) {
                final newOffset = widget.controller.offset - details.delta.dy;

                if (newOffset >= 0 &&
                    newOffset <= widget.controller.position.maxScrollExtent) {
                  widget.controller.jumpTo(newOffset);
                }
              },

              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                final offset = widget.controller.offset;

                int targetIndex = (offset / _cardHeight).round();

                /// If user flicks → respect velocity
                if (velocity < -200) {
                  targetIndex += 1;
                } else if (velocity > 200) {
                  targetIndex -= 1;
                }

                targetIndex = targetIndex.clamp(0, widget.itemCount - 1);

                widget.controller.animateTo(
                  targetIndex * _cardHeight,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                );
              },

              child: Stack(
                children: [
                  /// NEXT CARD — FIXED BEHIND
                  if (_currentIndex + 1 < widget.itemCount)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: widget.itemBuilder(context, _currentIndex + 1),
                      ),
                    ),

                  /// CURRENT CARD — REMOVED ON SCROLL
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (_, __) {
                        final offset = widget.controller.offset;
                        final base = _currentIndex * _cardHeight;
                        final progress = ((offset - base) / _cardHeight).clamp(
                          0.0,
                          1.0,
                        );

                        return Transform.translate(
                          offset: Offset(0, -_cardHeight * 1.7 * progress),
                          child: Opacity(
                            opacity: 1.0 - progress,
                            child: RepaintBoundary(
                              child: widget.itemBuilder(context, _currentIndex),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
