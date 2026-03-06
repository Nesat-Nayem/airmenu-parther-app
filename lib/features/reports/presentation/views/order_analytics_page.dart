import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/features/reports/data/repositories/api_reports_repository.dart';

/// Order Analytics Detail Page - With hover effects
class OrderAnalyticsPage extends StatefulWidget {
  const OrderAnalyticsPage({super.key});

  @override
  State<OrderAnalyticsPage> createState() => _OrderAnalyticsPageState();
}

class _OrderAnalyticsPageState extends State<OrderAnalyticsPage> {
  final ApiReportsRepository _repo = ApiReportsRepository();
  bool _isLoading = true;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _todayOrders = 0;
  int _completedBookings = 0;
  List<_DayOrders> _dailyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _repo.fetchReportStatsRaw();

      // Build daily order counts
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));
      final ordersData = await _repo.fetchOrdersRaw(
        page: 1,
        limit: 1000,
        startDate: sevenDaysAgo.toIso8601String().split('T')[0],
        endDate: now.toIso8601String().split('T')[0],
      );

      final List<dynamic> orders = ordersData['orders'] ?? [];
      final Map<String, int> dailyCounts = {};
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final key = '${months[date.month - 1]} ${date.day}';
        dailyCounts[key] = 0;
      }
      for (final order in orders) {
        final createdAt = order['createdAt'];
        if (createdAt != null) {
          final date = DateTime.tryParse(createdAt.toString());
          if (date != null) {
            final key = '${months[date.month - 1]} ${date.day}';
            dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
          }
        }
      }

      setState(() {
        _totalOrders = (stats['totalOrders'] as num?)?.toInt() ?? 0;
        _pendingOrders = (stats['pendingOrders'] as num?)?.toInt() ?? 0;
        _todayOrders = (stats['todayOrders'] as num?)?.toInt() ?? 0;
        _completedBookings = (stats['completedBookings'] as num?)?.toInt() ?? 0;
        _dailyData = dailyCounts.entries
            .map((e) => _DayOrders(date: e.key, orders: e.value))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Order Analytics',
      subtitle: 'Order volumes, types, and trends',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
            child: _StatItem(label: 'Total Orders', value: '$_totalOrders'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Today', value: '$_todayOrders'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Pending', value: '$_pendingOrders'),
          ),
          _VerticalDivider(),
          Expanded(
            child: _StatItem(label: 'Bookings Done', value: '$_completedBookings'),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_dailyData.isEmpty) {
      return HoverCard(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 320,
          child: Center(
            child: Text(
              'No order data available',
              style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
            ),
          ),
        ),
      );
    }

    final maxOrders = _dailyData
        .map((d) => d.orders)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = maxOrders > 0 ? (maxOrders * 1.2).ceil().toDouble() : 10.0;

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
              children: [chartMax.toInt(), (chartMax * 0.75).toInt(), (chartMax * 0.5).toInt(), (chartMax * 0.25).toInt(), 0]
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
                children: _dailyData.map((item) {
                  final height = (item.orders / chartMax) * 260;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _BarItem(
                        date: item.date,
                        orders: item.orders,
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

class _DayOrders {
  final String date;
  final int orders;
  const _DayOrders({required this.date, required this.orders});
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
