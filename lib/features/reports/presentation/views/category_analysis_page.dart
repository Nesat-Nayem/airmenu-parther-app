import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_shared_components.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';

/// Category Analysis Report Detail Page - With hover effects
class CategoryAnalysisPage extends StatefulWidget {
  const CategoryAnalysisPage({super.key});

  @override
  State<CategoryAnalysisPage> createState() => _CategoryAnalysisPageState();
}

class _CategoryAnalysisPageState extends State<CategoryAnalysisPage> {
  bool _isLoading = true;
  List<_CategoryData> _categoryData = [];

  static const _chartColors = [
    AirMenuColors.primary,
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF6B7280),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final hotelId = await locator<LocalStorage>().getString(localStorageKey: 'hotelId');
      if (hotelId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await locator<ApiService>().invoke(
        urlPath: '/hotels/$hotelId/menu',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> categories = data['data'] is List ? data['data'] : [];
          final List<_CategoryData> catData = [];
          int totalItems = 0;

          for (final cat in categories) {
            final items = cat['items'] as List? ?? [];
            totalItems += items.length;
          }

          int colorIdx = 0;
          for (final cat in categories) {
            final name = cat['name'] ?? cat['title'] ?? 'Unknown';
            final items = cat['items'] as List? ?? [];
            final itemCount = items.length;
            final percentage = totalItems > 0 ? ((itemCount / totalItems) * 100).round() : 0;

            catData.add(_CategoryData(
              name: name,
              value: itemCount,
              percentage: percentage,
              color: _chartColors[colorIdx % _chartColors.length],
            ));
            colorIdx++;
          }

          setState(() {
            _categoryData = catData;
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReportPageLayout(
      title: 'Category Analysis',
      subtitle: 'Performance by menu category',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChartSection(),
    );
  }

  Widget _buildChartSection() {
    if (_categoryData.isEmpty) {
      return HoverCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No menu categories found',
            style: AirMenuTextStyle.normal.withColor(Colors.grey.shade500),
          ),
        ),
      );
    }

    return HoverCard(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(
                  height: 280,
                  width: 280,
                  child: CustomPaint(
                    painter: _DonutChartPainter(categories: _categoryData),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _categoryData
                      .map(
                        (cat) => _LegendItem(name: cat.name, color: cat.color),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            flex: 1,
            child: Column(
              children: _categoryData
                  .map((cat) => _CategoryRow(data: cat))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final int value;
  final int percentage;
  final Color color;

  const _CategoryData({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class _CategoryRow extends StatefulWidget {
  final _CategoryData data;

  const _CategoryRow({required this.data});

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.data.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.data.name,
                style: AirMenuTextStyle.normal.bold600().withColor(
                  Colors.grey.shade800,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNumber(widget.data.value),
                  style: AirMenuTextStyle.normal.bold700().withColor(
                    Colors.grey.shade900,
                  ),
                ),
                Text(
                  '${widget.data.percentage}% of total',
                  style: AirMenuTextStyle.tiny.withColor(Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(0)},${((value % 100000) ~/ 1000).toString().padLeft(2, '0')},000';
    } else if (value >= 1000) {
      return '₹${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return '₹$value';
  }
}

class _LegendItem extends StatelessWidget {
  final String name;
  final Color color;

  const _LegendItem({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
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
          name,
          style: AirMenuTextStyle.small.withColor(Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_CategoryData> categories;

  _DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final strokeWidth = 40.0;

    double startAngle = -math.pi / 2;
    final total = categories.fold(0.0, (sum, cat) => sum + cat.percentage);

    for (final category in categories) {
      final sweepAngle = (category.percentage / total) * 2 * math.pi;
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.02,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
