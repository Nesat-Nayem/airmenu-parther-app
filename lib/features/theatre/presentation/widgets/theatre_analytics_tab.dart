import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/theatre_models.dart';

class TheatreAnalyticsTab extends StatelessWidget {
  final List<AnalyticsOrder> orders;
  final List<AnalyticsSku> skus;

  const TheatreAnalyticsTab({
    super.key,
    required this.orders,
    required this.skus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders per Interval',
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        // Bar Chart
        SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: orders.map((order) => _buildBar(order)).toList(),
          ),
        ),

        const SizedBox(height: 48),

        Text(
          'Bestselling SKUs',
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ...skus.asMap().entries.map(
          (entry) => _buildSkuRow(entry.key + 1, entry.value),
        ),
      ],
    );
  }

  Widget _buildBar(AnalyticsOrder order) {
    // scale max value approx 300
    final double height = (order.orders / 300) * 250;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _HoverableBar(height: height, value: order.orders),
        const SizedBox(height: 8),
        Text(
          order.time,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSkuRow(int rank, AnalyticsSku sku) {
    final double widthFactor = (sku.value / 50000); // approx max value

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              sku.name,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), // Light red bg
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: widthFactor.clamp(0.0, 1.0),
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rank.toString(),
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Assuming value is price/revenue
                Text(
                  '₹${sku.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.bold,
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

class _HoverableBar extends StatefulWidget {
  final double height;
  final int value;

  const _HoverableBar({required this.height, required this.value});

  @override
  State<_HoverableBar> createState() => _HoverableBarState();
}

class _HoverableBarState extends State<_HoverableBar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: '${widget.value} Orders',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFFB91C1C)
                : const Color(0xFFDC2626), // Darker on hover
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
