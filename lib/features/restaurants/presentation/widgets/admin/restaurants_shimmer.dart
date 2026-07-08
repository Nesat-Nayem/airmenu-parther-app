import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantsShimmer extends StatelessWidget {
  const RestaurantsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFCFBF9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar: search + filter + add
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: _box(height: 44, radius: 12),
                      ),
                      const SizedBox(width: 10),
                      _box(height: 44, width: 44, radius: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _box(height: 44, width: 160, radius: 999),
              ],
            ),
            const SizedBox(height: 20),
            // Stats
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
                    child: _box(height: 96, radius: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // List cards
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _box(height: 132, radius: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double height,
    double? width,
    double radius = 12,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEDE8E6),
      highlightColor: const Color(0xFFF8F5F3),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
