import 'package:flutter/material.dart';

/// Placeholder rows shown while the board's first fetch is in flight.
///
/// Port of iOS's `WishlistSkeletonView`. The Flutter SDK showed a centred
/// spinner, which reads as "the app is stuck" rather than "content is arriving":
/// the board has a known shape, so showing that shape is more reassuring than
/// showing nothing.
class WishlistSkeleton extends StatefulWidget {
  /// How many placeholder rows to draw.
  ///
  /// Not tied to the real list — the counts are not known yet — just enough to
  /// fill a phone screen.
  final int rows;

  const WishlistSkeleton({super.key, this.rows = 5});

  @override
  State<WishlistSkeleton> createState() => _WishlistSkeletonState();
}

class _WishlistSkeletonState extends State<WishlistSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ExcludeSemantics(
      // Purely decorative. A screen reader announcing five "loading" rows is
      // noise, and the board sets its own busy state around it.
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          final tint = Color.lerp(
            base,
            base.withValues(alpha: 0.35),
            _shimmer.value,
          )!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.rows,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 56, height: 52, color: tint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Block(
                          // Varying the width keeps the rows from looking like a
                          // rendering bug rather than a placeholder.
                          width: index.isEven ? 220 : 160,
                          height: 16,
                          color: tint,
                        ),
                        const SizedBox(height: 8),
                        _Block(
                          width: double.infinity,
                          height: 12,
                          color: tint,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
