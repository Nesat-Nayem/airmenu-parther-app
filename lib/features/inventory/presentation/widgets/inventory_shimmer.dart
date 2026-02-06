import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

class InventoryShimmer extends StatelessWidget {
  const InventoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid Shimmer
          const _StatsGridShimmer(),
          const SizedBox(height: 24),

          // Critical Alert Shimmer
          const _CriticalAlertShimmer(),
          const SizedBox(height: 24),

          // Search Bar Shimmer
          Shimmer.fromColors(
            baseColor: InventoryColors.shimmerBase,
            highlightColor: InventoryColors.shimmerHighlight,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Table Shimmer
          const _TableShimmer(),
        ],
      ),
    );
  }
}

class _StatsGridShimmer extends StatelessWidget {
  const _StatsGridShimmer();

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildCard()),
            ],
          ),
          const SizedBox(height: 12),
          _buildCard(),
        ],
      );
    }

    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Shimmer.fromColors(
      baseColor: InventoryColors.shimmerBase,
      highlightColor: InventoryColors.shimmerHighlight,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _CriticalAlertShimmer extends StatelessWidget {
  const _CriticalAlertShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: InventoryColors.shimmerBase,
      highlightColor: InventoryColors.shimmerHighlight,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _TableShimmer extends StatelessWidget {
  const _TableShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: InventoryColors.shimmerBase,
      highlightColor: InventoryColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white)),
              ),
            ),
            // Rows
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 120, height: 16, color: Colors.white),
                    Container(width: 80, height: 16, color: Colors.white),
                    Container(width: 60, height: 16, color: Colors.white),
                    Container(width: 80, height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
