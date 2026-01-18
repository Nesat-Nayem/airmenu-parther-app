import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Restaurant performance table widget
class RestaurantPerformanceTable extends StatefulWidget {
  final List<RestaurantPerformanceModel> restaurants;

  const RestaurantPerformanceTable({super.key, required this.restaurants});

  @override
  State<RestaurantPerformanceTable> createState() =>
      _RestaurantPerformanceTableState();
}

class _RestaurantPerformanceTableState
    extends State<RestaurantPerformanceTable> {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Performance',
                      style: AirMenuTextStyle.subheadingH5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time SLA heatmaps',
                      style: AirMenuTextStyle.caption.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                // Status legend
                Row(
                  children: [
                    _buildStatusIndicator('Good', const Color(0xFF10B981)),
                    const SizedBox(width: 12),
                    _buildStatusIndicator('Warning', const Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    _buildStatusIndicator('Critical', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Empty state or table
            Expanded(
              child: widget.restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Performance Data Available',
                            style: AirMenuTextStyle.subheadingH5.copyWith(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Restaurant performance metrics will appear here',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          // Header row
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            children: [
                              _buildHeaderCell('RESTAURANT'),
                              _buildHeaderCell('ORDERS'),
                              _buildHeaderCell('SLA %'),
                              _buildHeaderCell('PREP TIME'),
                              _buildHeaderCell('QUEUE'),
                            ],
                          ),
                          // Data rows
                          ...widget.restaurants.map(
                            (restaurant) => _buildDataRow(restaurant),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: AirMenuTextStyle.caption.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildDataRow(RestaurantPerformanceModel restaurant) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      children: [
        _buildDataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              restaurant.restaurantName,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        _buildDataCell(
          _buildBadge(
            restaurant.orders.toString(),
            AirMenuColors.primary.withOpacity(0.1),
            AirMenuColors.primary,
          ),
        ),
        _buildDataCell(
          _buildBadge(
            '${restaurant.slaPercentage.toInt()}%',
            _getSLAColor(restaurant.slaPercentage).withOpacity(0.1),
            _getSLAColor(restaurant.slaPercentage),
          ),
        ),
        _buildDataCell(
          _buildBadge(
            restaurant.avgPrepTime,
            _getPrepTimeColor(restaurant.avgPrepTime).withOpacity(0.1),
            _getPrepTimeColor(restaurant.avgPrepTime),
          ),
        ),
        _buildDataCell(
          _buildBadge(
            restaurant.currentQueue.toString(),
            _getQueueColor(restaurant.currentQueue).withOpacity(0.1),
            _getQueueColor(restaurant.currentQueue),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AirMenuTextStyle.small.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getSLAColor(double sla) {
    if (sla >= 90) {
      return const Color(0xFF10B981); // Good
    } else if (sla >= 75) {
      return const Color(0xFFF59E0B); // Warning
    } else {
      return const Color(0xFFEF4444); // Critical
    }
  }

  Color _getPrepTimeColor(String prepTime) {
    final minutes = int.tryParse(prepTime.replaceAll('m', '')) ?? 0;
    if (minutes <= 18) {
      return const Color(0xFF10B981); // Good
    } else if (minutes <= 24) {
      return const Color(0xFFF59E0B); // Warning
    } else {
      return const Color(0xFFEF4444); // Critical
    }
  }

  Color _getQueueColor(int queue) {
    if (queue <= 10) {
      return const Color(0xFF10B981); // Good
    } else if (queue <= 20) {
      return const Color(0xFFF59E0B); // Warning
    } else {
      return const Color(0xFFEF4444); // Critical
    }
  }
}
