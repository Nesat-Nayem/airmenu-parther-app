import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/features/reports/data/repositories/api_reports_repository.dart';

/// Sales Report Detail Page - With hover effects
class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final ApiReportsRepository _repo = ApiReportsRepository();
  bool _isLoading = true;
  double _totalRevenue = 0;
  double _avgDailySales = 0;
  double _avgOrderValue = 0;
  int _todayOrders = 0;
  List<_DailyData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _repo.fetchReportStatsRaw();
      final chartPoints = await _repo.getChartData();

      final totalOrders = (stats['totalOrders'] as num?)?.toInt() ?? 0;
      final totalRevenue = (stats['totalRevenue'] as num?)?.toDouble() ?? 0;
      final todayOrders = (stats['todayOrders'] as num?)?.toInt() ?? 0;

      setState(() {
        _totalRevenue = totalRevenue;
        _todayOrders = todayOrders;
        _avgDailySales = chartPoints.isNotEmpty
            ? totalRevenue / chartPoints.length
            : 0;
        _avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
        _chartData = chartPoints
            .map((p) => _DailyData(date: p.date, value: p.value))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Sales Report',
      subtitle: 'Daily, weekly, and monthly sales analysis',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  _formatCurrency(_totalRevenue),
                  style: AirMenuTextStyle.headingH3.bold700().withColor(
                    AirMenuColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+$_todayOrders orders today',
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
                  _formatCurrency(_avgDailySales),
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
                  _formatCurrency(_avgOrderValue),
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
    if (_chartData.isEmpty) {
      return HoverCard(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 300,
          child: Center(
            child: Text(
              'No sales data available',
              style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
            ),
          ),
        ),
      );
    }

    return HoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: _AreaChartPainter(data: _chartData),
              child: Container(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _chartData
                  .map(
                    (d) => Text(
                      d.date,
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

class _DailyData {
  final String date;
  final double value;
  const _DailyData({required this.date, required this.value});
}

class _AreaChartPainter extends CustomPainter {
  final List<_DailyData> data;
  _AreaChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

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

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxValue > 0 ? maxValue : 1.0;
    final dataPoints = data.map((d) => d.value / normalizedMax).toList();

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = dataPoints.length > 1
          ? (size.width / (dataPoints.length - 1)) * i
          : size.width / 2;
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
      final x = dataPoints.length > 1
          ? (size.width / (dataPoints.length - 1)) * i
          : size.width / 2;
      final y = size.height - (dataPoints[i] * size.height * 0.8);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
