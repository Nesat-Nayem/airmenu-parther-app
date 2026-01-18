import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:fl_chart/fl_chart.dart';

/// Rider SLA comparison chart widget
class RiderSLAChart extends StatefulWidget {
  final List<RiderSLAModel> riders;

  const RiderSLAChart({super.key, required this.riders});

  @override
  State<RiderSLAChart> createState() => _RiderSLAChartState();
}

class _RiderSLAChartState extends State<RiderSLAChart> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withOpacity(0.1)
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
                  'Rider SLA Comparison',
                  style: AirMenuTextStyle.subheadingH5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Partner performance metrics',
                  style: AirMenuTextStyle.caption.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Empty state or chart
            Expanded(
              child: widget.riders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining_outlined,
                            size: 64,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Rider Data Available',
                            style: AirMenuTextStyle.subheadingH5.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rider SLA metrics will appear here once available',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : BarChart(
                      _buildChartData(),
                      swapAnimationDuration: const Duration(milliseconds: 250),
                    ),
            ),
            if (widget.riders.isNotEmpty) const SizedBox(height: 16),
            // Legend
            if (widget.riders.isNotEmpty) _buildLegend(),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 100,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black87,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final rider = widget.riders[groupIndex];
            return BarTooltipItem(
              '${rider.partnerName}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: 'Success: ${rider.slaPercentage.toInt()}%\n',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Avg Delivery: ${rider.avgDeliveryTime}\n',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        ),
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
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < widget.riders.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.riders[value.toInt()].partnerName,
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Text('');
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: AirMenuTextStyle.caption.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: const Color(0xFFF3F4F6), strokeWidth: 1);
        },
      ),
      barGroups: widget.riders.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.slaPercentage,
              gradient: LinearGradient(
                colors: [AirMenuColors.primary, AirMenuColors.primary.shade3],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 40,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('SLA %', AirMenuColors.primary),
        const SizedBox(width: 16),
        _buildLegendItem('Avg Time', const Color(0xFF6B7280)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
