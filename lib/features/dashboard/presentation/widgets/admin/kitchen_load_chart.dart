import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:fl_chart/fl_chart.dart';

/// Kitchen load vs time chart widget
class KitchenLoadChart extends StatefulWidget {
  final KitchenLoadChartModel? data;

  const KitchenLoadChart({super.key, required this.data});

  @override
  State<KitchenLoadChart> createState() => _KitchenLoadChartState();
}

class _KitchenLoadChartState extends State<KitchenLoadChart> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 12.0 : 20.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : const Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 16 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kitchen Load vs Time',
                  style: AirMenuTextStyle.subheadingH5.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Network-wide average',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Empty state or chart
            Expanded(
              child: widget.data == null || widget.data?.labels.isEmpty == true
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Kitchen Load Data Available',
                            style: AirMenuTextStyle.subheadingH5.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kitchen load metrics will appear here',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : LineChart(
                      _buildChartData(),
                      duration: const Duration(milliseconds: 250),
                    ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            // Legend - wraps automatically
            if (widget.data != null && widget.data?.labels.isNotEmpty == true)
              _buildLegend(isMobile),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    // Handle null or empty widget.data
    if (widget.data == null || widget.data?.labels.isEmpty == true) {
      return LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    final chartData = widget.data;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 2,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < (chartData?.labels.length ?? 0)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartData?.labels[index] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: ((chartData?.labels.length ?? 0) - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots:
              chartData?.loadPercentages
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                  .toList() ??
              [],
          isCurved: true,
          color: AirMenuColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _getColorForLoad(
                  chartData?.loadPercentages[index].toDouble() ?? 0,
                ),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AirMenuColors.primary.withOpacity(0.2),
                AirMenuColors.primary.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              final label = chartData?.labels[index] ?? '';
              final loadPercent = chartData?.loadPercentages[index] ?? 0;
              final status = _getStatusForLoad(loadPercent.toDouble());
              return LineTooltipItem(
                '$label\n$loadPercent% ${status.toUpperCase()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Color _getColorForLoad(double load) {
    if (load >= 85) {
      return const Color(0xFFEF4444); // Critical - Red
    } else if (load >= 70) {
      return const Color(0xFFF59E0B); // High - Orange
    } else {
      return const Color(0xFF10B981); // Normal - Green
    }
  }

  String _getStatusForLoad(double load) {
    if (load >= 85) {
      return 'critical';
    } else if (load >= 70) {
      return 'high';
    } else {
      return 'normal';
    }
  }

  Widget _buildLegend(bool isMobile) {
    return Wrap(
      spacing: isMobile ? 8 : 16,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Normal (<70%)', const Color(0xFF10B981), isMobile),
        _buildLegendItem('High (70-85%)', const Color(0xFFF59E0B), isMobile),
        _buildLegendItem('Critical (>85%)', const Color(0xFFEF4444), isMobile),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: isMobile ? 10 : 12,
          ),
        ),
      ],
    );
  }
}
