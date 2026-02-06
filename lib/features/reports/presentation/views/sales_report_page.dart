import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';

/// Sales Report Detail Page - With hover effects
class SalesReportPage extends StatelessWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Sales Report',
      subtitle: 'Daily, weekly, and monthly sales analysis',
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildSalesChart(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEE2E2), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹4,01,000',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+15% vs last week',
                  style: AirMenuTextStyle.tiny.withColor(
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFFEF3C7), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg Daily Sales',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹57,285',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverCard(
            gradientColors: [const Color(0xFFD1FAE5), Colors.white],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avg Order Value',
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹398',
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: _AreaChartPainter(),
              child: Container(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  [
                        'Dec 7',
                        'Dec 8',
                        'Dec 9',
                        'Dec 10',
                        'Dec 11',
                        'Dec 12',
                        'Dec 13',
                      ]
                      .map(
                        (date) => Text(
                          date,
                          style: AirMenuTextStyle.tiny.withColor(
                            Colors.grey.shade500,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AirMenuColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AirMenuColors.primary.withValues(alpha: 0.3),
          AirMenuColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dataPoints = [0.4, 0.5, 0.45, 0.6, 0.55, 0.7, 0.8];
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = size.height - (dataPoints[i] * size.height * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = AirMenuColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = size.height - (dataPoints[i] * size.height * 0.8);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
