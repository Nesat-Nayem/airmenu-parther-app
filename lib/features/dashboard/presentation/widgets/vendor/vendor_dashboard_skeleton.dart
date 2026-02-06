import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:shimmer/shimmer.dart';

class VendorDashboardSkeleton extends StatelessWidget {
  const VendorDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton (Search + Filters)
            Row(
              children: [
                Expanded(
                  child: _buildSkeletonBox(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 12,
                  ),
                ), // Search
                const SizedBox(width: 8),
                _buildSkeletonBox(width: 1, height: 32), // Divider
                const SizedBox(width: 8),
                _buildSkeletonBox(
                  width: 100,
                  height: 44,
                  borderRadius: 12,
                ), // Filter 1
                const SizedBox(width: 8),
                _buildSkeletonBox(
                  width: 150,
                  height: 44,
                  borderRadius: 12,
                ), // Filter 2
                const SizedBox(width: 8),
                _buildSkeletonBox(
                  width: 120,
                  height: 44,
                  borderRadius: 12,
                ), // Filter 3
              ],
            ),
            const SizedBox(height: 32),

            // Stat cards skeleton
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                if (isMobile) {
                  // Mobile: 1 column list
                  return Column(
                    children: List.generate(
                      6,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStatCardSkeleton(),
                      ),
                    ),
                  );
                } else {
                  // Desktop/Tablet: 6 columns
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.55,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildStatCardSkeleton(),
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Charts section skeleton
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1200;

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChartSkeleton(height: 300)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChartSkeleton(height: 300)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildChartSkeleton(height: 300),
                      const SizedBox(height: 16),
                      _buildChartSkeleton(height: 300),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Bottom section skeleton
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1200;

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChartSkeleton(height: 350)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildChartSkeleton(height: 350)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildChartSkeleton(height: 350),
                      const SizedBox(height: 16),
                      _buildChartSkeleton(height: 350),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 32),

            // Table skeleton
            _buildTableSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AirMenuColors.borderDefault, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSkeletonBox(width: 48, height: 48, borderRadius: 12),
                const Spacer(),
                _buildSkeletonBox(width: 60, height: 24, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkeletonBox(width: 100, height: 36),
            const SizedBox(height: 8),
            _buildSkeletonBox(width: 150, height: 16),
            const SizedBox(height: 4),
            _buildSkeletonBox(width: 100, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSkeleton({required double height}) {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AirMenuColors.borderDefault, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonBox(width: 200, height: 24),
              const SizedBox(height: 8),
              _buildSkeletonBox(width: 150, height: 14),
              const SizedBox(height: 24),
              Expanded(
                child: _buildSkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSkeleton() {
    return Shimmer.fromColors(
      baseColor: AirMenuColors.borderDefault,
      highlightColor: AirMenuColors.backgroundSecondary,
      child: Container(
        decoration: BoxDecoration(
          color: AirMenuColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AirMenuColors.borderDefault, width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _buildSkeletonBox(width: 200, height: 24),
                  const Spacer(),
                  _buildSkeletonBox(width: 120, height: 40),
                ],
              ),
            ),
            ...List.generate(
              5,
              (index) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AirMenuColors.borderDefault,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildSkeletonBox(width: 80, height: 20),
                    const SizedBox(width: 24),
                    _buildSkeletonBox(width: 100, height: 20),
                    const SizedBox(width: 24),
                    _buildSkeletonBox(width: 60, height: 20),
                    const Spacer(),
                    _buildSkeletonBox(width: 80, height: 24, borderRadius: 8),
                  ],
                ),
              ),
            ),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AirMenuColors.borderDefault,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
