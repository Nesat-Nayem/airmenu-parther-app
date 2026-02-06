import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickOverviewChart extends StatefulWidget {
  final List<ChartDataPoint> data;

  const QuickOverviewChart({super.key, required this.data});

  @override
  State<QuickOverviewChart> createState() => _QuickOverviewChartState();
}

class _QuickOverviewChartState extends State<QuickOverviewChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final minValue = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);

    // Extend range for better visualization
    final displayMax = maxValue * 1.1;
    final displayMin = 0.0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Quick Overview - This Week',
            style: AirMenuTextStyle.headingH4.bold700().withColor(
              Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 40),

          // Chart Area
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = constraints.maxWidth - 60;
                final chartHeight = constraints.maxHeight;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Y-Axis Labels (5 labels)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(5, (index) {
                          final value =
                              displayMax -
                              (index * (displayMax - displayMin) / 4);
                          return Text(
                            '₹${(value / 1000).toStringAsFixed(0)}k',
                            style: AirMenuTextStyle.tiny.withColor(
                              Colors.grey.shade400,
                            ),
                          );
                        }),
                      ),
                    ),

                    // Chart Area
                    Positioned(
                      left: 60,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: ClipRect(
                        child: CustomPaint(
                          size: Size(chartWidth, chartHeight),
                          painter: _GradientChartPainter(
                            data: widget.data,
                            maxValue: displayMax,
                            minValue: displayMin,
                            hoveredIndex: _hoveredIndex,
                          ),
                        ),
                      ),
                    ),

                    // Interactive Hover Layer
                    Positioned(
                      left: 60,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        children: List.generate(
                          widget.data.length,
                          (index) => Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) =>
                                  setState(() => _hoveredIndex = index),
                              onExit: (_) =>
                                  setState(() => _hoveredIndex = null),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tooltip
                    if (_hoveredIndex != null)
                      _buildTooltip(
                        chartWidth,
                        chartHeight,
                        displayMax,
                        displayMin,
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // X-Axis Labels
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.data.map((point) {
                return Text(
                  point.date,
                  style: AirMenuTextStyle.small.withColor(Colors.grey.shade500),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTooltip(
    double chartWidth,
    double chartHeight,
    double maxValue,
    double minValue,
  ) {
    final range = maxValue - minValue;
    final pointSpacing = chartWidth / (widget.data.length - 1);
    final x = 60 + (_hoveredIndex! * pointSpacing);
    final normalizedValue =
        (widget.data[_hoveredIndex!].value - minValue) / range;
    final y = chartHeight - (normalizedValue * chartHeight);

    return Positioned(
      left: x - 50,
      top: y - 65,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.data[_hoveredIndex!].date,
              style: AirMenuTextStyle.tiny.withColor(Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'sales : ${widget.data[_hoveredIndex!].value.toInt()}',
              style: AirMenuTextStyle.small.bold600().withColor(
                AirMenuColors.primary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 150.ms),
    );
  }
}

class _GradientChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double maxValue;
  final double minValue;
  final int? hoveredIndex;

  _GradientChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final range = maxValue - minValue;
    final pointSpacing = size.width / (data.length - 1);
    final points = <Offset>[];

    // Calculate all points
    for (var i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Create smooth curve path using quadratic bezier
    final linePath = Path();
    final fillPath = Path();

    fillPath.moveTo(0, size.height);

    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        // Use quadratic bezier for smooth curves
        final prevPoint = points[i - 1];
        final currentPoint = points[i];
        final controlX = (prevPoint.dx + currentPoint.dx) / 2;

        linePath.quadraticBezierTo(
          controlX,
          prevPoint.dy,
          controlX,
          (prevPoint.dy + currentPoint.dy) / 2,
        );
        linePath.quadraticBezierTo(
          controlX,
          currentPoint.dy,
          currentPoint.dx,
          currentPoint.dy,
        );

        fillPath.quadraticBezierTo(
          controlX,
          prevPoint.dy,
          controlX,
          (prevPoint.dy + currentPoint.dy) / 2,
        );
        fillPath.quadraticBezierTo(
          controlX,
          currentPoint.dy,
          currentPoint.dx,
          currentPoint.dy,
        );
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // BEAUTIFUL GRADIENT FILL - Made much more visible!
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AirMenuColors.primary.withValues(alpha: 0.35), // Strong red at top
          const Color(0xFFFECACA).withValues(alpha: 0.25), // Light pink mid
          const Color(
            0xFFFEF2F2,
          ).withValues(alpha: 0.15), // Very light at bottom
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw gradient fill FIRST
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AirMenuColors.primary;

    canvas.drawPath(linePath, linePaint);

    // Draw points
    final pointFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = AirMenuColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var i = 0; i < points.length; i++) {
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 7.0 : 5.0;

      // Draw white fill
      canvas.drawCircle(points[i], radius, pointFillPaint);
      // Draw red border
      canvas.drawCircle(points[i], radius, pointBorderPaint);

      // Add glow effect on hover
      if (isHovered) {
        final glowPaint = Paint()
          ..color = AirMenuColors.primary.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], 12, glowPaint);
        canvas.drawCircle(points[i], radius, pointFillPaint);
        canvas.drawCircle(points[i], radius, pointBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GradientChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.data != data;
  }
}
