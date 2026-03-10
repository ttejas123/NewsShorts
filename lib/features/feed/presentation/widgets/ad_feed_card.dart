import 'package:flutter/material.dart';

class AdFeedCard extends StatelessWidget {
  final Widget ad;

  const AdFeedCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 560, // EXACT same height as StandardVisualCard
      color: colors.surface,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: ad),

                /// Sponsored label
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Sponsored",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}