import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:fl_chart/fl_chart.dart';

/// Orders by type chart widget
class OrdersByTypeChart extends StatefulWidget {
  final OrdersByTypeChartModel? data;
  final String currentView;
  final Function(String)? onViewChanged;

  const OrdersByTypeChart({
    super.key,
    required this.data,
    this.currentView = 'today',
    this.onViewChanged,
  });

  @override
  State<OrdersByTypeChart> createState() => _OrdersByTypeChartState();
}

class _OrdersByTypeChartState extends State<OrdersByTypeChart> {
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
            // Header with title and filter tabs - responsive layout
            isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
            SizedBox(height: isMobile ? 16 : 24),
            // Empty state or chart
            Expanded(
              child: widget.data == null || widget.data?.labels.isEmpty == true
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 64,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Orders Data Available',
                            style: AirMenuTextStyle.subheadingH5.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Order distribution data will appear here',
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
              _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders by Type',
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Multi-channel order distribution',
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF9CA3AF),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilterTabs(compact: true),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders by Type',
                style: AirMenuTextStyle.subheadingH5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Multi-channel order distribution',
                style: AirMenuTextStyle.caption.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        _buildFilterTabs(compact: false),
      ],
    );
  }

  Widget _buildFilterTabs({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 2 : 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab('Today', 'today', compact),
          _buildTab('Week', 'week', compact),
          _buildTab('Month', 'month', compact),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, bool compact) {
    final isSelected = widget.currentView == value;
    return GestureDetector(
      onTap: () => widget.onViewChanged?.call(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AirMenuColors.primary : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: compact ? 11 : 13,
          ),
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 40,
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (widget.data != null &&
                  value.toInt() >= 0 &&
                  value.toInt() < (widget.data?.labels.length ?? 0)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.data?.labels[value.toInt()] ?? '',
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
            interval: 40,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: ((widget.data?.labels.length ?? 1) - 1).toDouble(),
      minY: 0,
      maxY: 150,
      lineBarsData: [
        _buildLineChartBarData(
          widget.data?.dineIn.map((e) => e.toDouble()).toList() ?? [],
          const Color(0xFFEF4444),
        ),
        _buildLineChartBarData(
          widget.data?.takeaway.map((e) => e.toDouble()).toList() ?? [],
          const Color(0xFFF59E0B),
        ),
        _buildLineChartBarData(
          widget.data?.qsr.map((e) => e.toDouble()).toList() ?? [],
          const Color(0xFF10B981),
        ),
        _buildLineChartBarData(
          widget.data?.roomService.map((e) => e.toDouble()).toList() ?? [],
          const Color(0xFF3B82F6),
        ),
        _buildLineChartBarData(
          widget.data?.theatre.map((e) => e.toDouble()).toList() ?? [],
          const Color(0xFF8B5CF6),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final labels = [
                'Dine-in',
                'Takeaway',
                'QSR',
                'Room Service',
                'Theatre',
              ];
              return LineTooltipItem(
                '${labels[spot.barIndex]}: ${spot.y.toInt()}',
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

  LineChartBarData _buildLineChartBarData(List<double> yValues, Color color) {
    return LineChartBarData(
      spots: yValues
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  Widget _buildLegend() {
    final items = [
      {'label': 'Dine-in', 'color': const Color(0xFFEF4444)},
      {'label': 'Takeaway', 'color': const Color(0xFFF59E0B)},
      {'label': 'QSR', 'color': const Color(0xFF10B981)},
      {'label': 'Room Service', 'color': const Color(0xFF3B82F6)},
      {'label': 'Theatre', 'color': const Color(0xFF8B5CF6)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item['label'] as String,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }
}
