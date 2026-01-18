import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class OrdersOverTimeChart extends StatelessWidget {
  final OrdersOverTimeModel data;
  final Function(String)? onPeriodChanged;
  final VoidCallback? onViewDetails;

  const OrdersOverTimeChart({
    super.key,
    required this.data,
    this.onPeriodChanged,
    this.onViewDetails,
  });

  static const double _chartSidePadding = 16;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AirMenuColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AirMenuColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          SizedBox(height: isMobile ? 16 : 24),
          _buildChart(isMobile),
        ],
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders Over Time',
                style: AirMenuTextStyle.headingH4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hourly order distribution',
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          TextButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('View Details'),
            style: TextButton.styleFrom(foregroundColor: AirMenuColors.primary),
          ),
      ],
    );
  }

  /// ---------------- CHART ----------------
  Widget _buildChart(bool isMobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: isMobile ? 250 : 280),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth = math.max(
            constraints.maxWidth,
            data.labels.length * 50.0,
          );

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _chartSidePadding,
                ),
                child: SizedBox(
                  width: chartWidth + (_chartSidePadding * 2),
                  height: constraints.maxHeight,
                  child: data.orderCounts.isEmpty
                      ? Center(
                          child: Text(
                            'No data available',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: AirMenuColors.textSecondary,
                            ),
                          ),
                        )
                      : LineChart(_buildChartData(isMobile)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------- CHART DATA ----------------
  LineChartData _buildChartData(bool isMobile) {
    return LineChartData(
      clipData: FlClipData.none(), // IMPORTANT
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: AirMenuColors.borderDefault, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < data.labels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data.labels[index],
                    style: AirMenuTextStyle.caption.copyWith(
                      color: AirMenuColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: isMobile ? 35 : 40,
            interval: 20,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: AirMenuTextStyle.caption.copyWith(
                  color: AirMenuColors.textSecondary,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.labels.length - 1).toDouble(),
      minY: 0,
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: _generateSpots(),
          isCurved: true,
          color: AirMenuColors.error,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AirMenuColors.error,
                strokeWidth: 2,
                strokeColor: AirMenuColors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AirMenuColors.error.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  /// ---------------- HELPERS ----------------
  List<FlSpot> _generateSpots() {
    return List.generate(
      data.orderCounts.length,
      (index) => FlSpot(index.toDouble(), data.orderCounts[index].toDouble()),
    );
  }

  double _getMaxY() {
    if (data.orderCounts.isEmpty) return 100;
    final maxValue = data.orderCounts.reduce((a, b) => a > b ? a : b);
    return (maxValue + 20).toDouble();
  }
}
