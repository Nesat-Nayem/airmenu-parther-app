import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class OrderTypeBreakdownChart extends StatefulWidget {
  final OrderTypeBreakdownModel data;

  const OrderTypeBreakdownChart({super.key, required this.data});

  @override
  State<OrderTypeBreakdownChart> createState() =>
      _OrderTypeBreakdownChartState();
}

class _OrderTypeBreakdownChartState extends State<OrderTypeBreakdownChart> {
  int touchedIndex = -1;

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
        border: Border.all(color: AirMenuColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Type Breakdown',
            style: AirMenuTextStyle.headingH4.copyWith(
              fontWeight: FontWeight.bold,
              color: AirMenuColors.textPrimary,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Distribution by type',
            style: AirMenuTextStyle.small.copyWith(
              color: AirMenuColors.textSecondary,
              fontSize: isMobile ? 11 : 12,
            ),
          ),
          const SizedBox(height: 32),
          if (widget.data.total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No data available',
                  style: AirMenuTextStyle.normal.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _generateSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLegend(),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    return [
      PieChartSectionData(
        value: widget.data.dineInCount.toDouble(),
        title: touchedIndex == 0 ? widget.data.dineInCount.toString() : '',
        titleStyle: AirMenuTextStyle.normal.copyWith(
          fontWeight: FontWeight.bold,
          color: AirMenuColors.white,
        ),
        color: AirMenuColors.error, // Red for Dine-in
        radius: touchedIndex == 0 ? 60 : 50,
      ),
      PieChartSectionData(
        value: widget.data.takeawayCount.toDouble(),
        title: touchedIndex == 1 ? widget.data.takeawayCount.toString() : '',
        titleStyle: AirMenuTextStyle.normal.copyWith(
          fontWeight: FontWeight.bold,
          color: AirMenuColors.white,
        ),
        color: const Color(0xFFF59E0B), // Orange for Takeaway
        radius: touchedIndex == 1 ? 60 : 50,
      ),
      PieChartSectionData(
        value: widget.data.deliveryCount.toDouble(),
        title: touchedIndex == 2 ? widget.data.deliveryCount.toString() : '',
        titleStyle: AirMenuTextStyle.normal.copyWith(
          fontWeight: FontWeight.bold,
          color: AirMenuColors.white,
        ),
        color: const Color(0xFF10B981), // Green for Delivery
        radius: touchedIndex == 2 ? 60 : 50,
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem(
          'Dine-in',
          AirMenuColors.error,
          widget.data.dineInCount,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          'Takeaway',
          const Color(0xFFF59E0B),
          widget.data.takeawayCount,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          'Delivery',
          const Color(0xFF10B981),
          widget.data.deliveryCount,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: AirMenuColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: AirMenuTextStyle.normal.copyWith(
            color: AirMenuColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
