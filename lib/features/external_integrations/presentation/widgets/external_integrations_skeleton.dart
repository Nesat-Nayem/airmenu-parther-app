import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../utils/colors/airmenu_color.dart';

class ExternalIntegrationsSkeleton extends StatelessWidget {
  const ExternalIntegrationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSkeletonBox(width: 300, height: 32),
          const SizedBox(height: 8),
          _buildSkeletonBox(width: 300, height: 16),
          const SizedBox(height: 32),

          // Stat cards skeleton
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildStatCardSkeleton(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Filter bar skeleton
          Row(
            children: [
              _buildSkeletonBox(width: 300, height: 44, borderRadius: 8),
              const SizedBox(width: 16),
              _buildSkeletonBox(width: 200, height: 44, borderRadius: 22),
            ],
          ),

          const SizedBox(height: 24),

          // Table Skeleton
          _buildTableSkeleton(),
        ],
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        height: 300, // Updated height
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AirMenuColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AirMenuColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const Spacer(),
            // Value
            Container(width: 100, height: 36, color: AirMenuColors.white),
            const SizedBox(height: 8),
            // Label
            Container(width: 80, height: 15, color: AirMenuColors.white),
            const SizedBox(height: 4),
            // Subtext
            Container(width: 60, height: 12, color: AirMenuColors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSkeleton() {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AirMenuColors.borderDefault),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = 4,
  }) {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AirMenuColors.borderDefault,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
