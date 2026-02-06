import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DeliveryPartnerStatsShimmer extends StatelessWidget {
  const DeliveryPartnerStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 16 : 0),
            child: _buildShimmerCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 300, // Updated to match new card height
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const Spacer(),
            // Value Placeholder
            Container(width: 120, height: 36, color: Colors.white),
            const SizedBox(height: 8),
            // Label Placeholder
            Container(width: 80, height: 15, color: Colors.white),
            const SizedBox(height: 4),
            // Subtext Placeholder
            Container(width: 60, height: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class DeliveryPartnerGridShimmer extends StatelessWidget {
  const DeliveryPartnerGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 300, // Fixed height for grid items
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 16, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(width: 150, height: 32, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 80, height: 15, color: Colors.white),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 60, height: 20, color: Colors.white),
                    Container(width: 60, height: 20, color: Colors.white),
                    Container(width: 60, height: 20, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 12, color: Colors.white),
                    Container(width: 40, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
