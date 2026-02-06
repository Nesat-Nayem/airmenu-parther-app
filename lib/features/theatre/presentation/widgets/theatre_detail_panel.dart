import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/theatre_models.dart';
import 'theatre_seat_map_tab.dart';
import 'theatre_intervals_tab.dart';
import 'theatre_analytics_tab.dart';

class TheatreDetailPanel extends StatefulWidget {
  final TheatreDetail detail;
  final VoidCallback onClose;

  const TheatreDetailPanel({
    super.key,
    required this.detail,
    required this.onClose,
  });

  @override
  State<TheatreDetailPanel> createState() => _TheatreDetailPanelState();
}

class _TheatreDetailPanelState extends State<TheatreDetailPanel> {
  String _selectedTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.movie_filter_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.detail.name,
                          style: AirMenuTextStyle.headingH4.copyWith(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF166534),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.detail.status,
                                style: AirMenuTextStyle.small.copyWith(
                                  color: const Color(0xFF166534),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.detail.city} • ${widget.detail.screens} screens • ${widget.detail.totalSeats} seats',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Tabs
          Row(
            children: [
              _buildTab('Overview'),
              const SizedBox(width: 24),
              _buildTab('Seat Map'),
              const SizedBox(width: 24),
              _buildTab('Intervals'),
              const SizedBox(width: 24),
              _buildTab('Analytics'),
            ],
          ),

          const SizedBox(height: 32),

          // Content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Text(
          title,
          style: AirMenuTextStyle.normal.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'Overview':
        return _buildOverview();
      case 'Seat Map':
        return const TheatreSeatMapTab(); // New Tab
      case 'Intervals':
        return TheatreIntervalsTab(
          intervals: widget.detail.intervals,
        ); // New Tab
      case 'Analytics':
        return TheatreAnalyticsTab(
          orders: widget.detail.orderAnalytics,
          skus: widget.detail.bestSellingSkus,
        ); // New Tab
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Grid (Left Side)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleStatCard(
                      Icons.chair_outlined,
                      widget.detail.totalSeats.toString(),
                      'Total Seats',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleStatCard(
                      Icons.tv_outlined,
                      widget.detail.intervalsPerDay.toString(),
                      'Intervals/Day',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSimpleStatCard(
                      Icons.shopping_bag_outlined,
                      widget.detail.ordersToday.toString(),
                      'Orders Today',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleStatCard(
                      Icons.currency_rupee,
                      '₹${widget.detail.avgOrderValue}',
                      'Avg Order',
                      isUp: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // Top Selling Items (Right Side)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Selling Items',
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.detail.topSellingItems.asMap().entries.map(
                (entry) => _buildTopSellingItem(entry.key + 1, entry.value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard(
    IconData icon,
    String value,
    String label, {
    bool? isUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // Very light grey
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFDC2626), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AirMenuTextStyle.headingH4.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            label,
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingItem(int rank, TopSellingItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
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
          Expanded(
            child: Text(
              item.name,
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Text(
            '${item.orders} orders',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.trend > 0 ? '+' : ''}${item.trend.toInt()}%',
            style: AirMenuTextStyle.small.copyWith(
              color: item.trend > 0
                  ? const Color(0xFF166534)
                  : const Color(0xFFDC2626),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
