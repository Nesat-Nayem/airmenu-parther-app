import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';

/// Order Analytics Detail Page - With hover effects
class OrderAnalyticsPage extends StatelessWidget {
  const OrderAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Order Analytics',
      subtitle: 'Order volumes, types, and trends',
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(label: 'Total Orders', value: '1,000'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Dine-In', value: '580'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Takeaway', value: '320'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Delivery', value: '100'),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final data = [
      {'date': 'Dec 7', 'orders': 110},
      {'date': 'Dec 8', 'orders': 145},
      {'date': 'Dec 9', 'orders': 132},
      {'date': 'Dec 10', 'orders': 168},
      {'date': 'Dec 11', 'orders': 155},
      {'date': 'Dec 12', 'orders': 180},
      {'date': 'Dec 13', 'orders': 175},
    ];
    final maxOrders = 200.0;

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 320,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [200, 150, 100, 50, 0]
                  .map(
                    (v) => Text(
                      '$v',
                      style: AirMenuTextStyle.tiny.withColor(
                        Colors.grey.shade500,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final height = ((item['orders'] as int) / maxOrders) * 260;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _BarItem(
                        date: item['date'] as String,
                        orders: item['orders'] as int,
                        height: height,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatefulWidget {
  final String date;
  final int orders;
  final double height;

  const _BarItem({
    required this.date,
    required this.orders,
    required this.height,
  });

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isHovered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    widget.date,
                    style: AirMenuTextStyle.tiny.withColor(Colors.white),
                  ),
                  Text(
                    'orders: ${widget.orders}',
                    style: AirMenuTextStyle.tiny.bold700().withColor(
                      AirMenuColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AirMenuColors.primary.withValues(alpha: 0.7)
                  : AirMenuColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.date,
            style: AirMenuTextStyle.tiny.withColor(Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.withColor(Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AirMenuTextStyle.headingH3.bold700().withColor(
            Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
