import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/hotel_models.dart';

class HotelDetailPanel extends StatelessWidget {
  final HotelDetail detail;
  final VoidCallback onClose;

  const HotelDetailPanel({
    super.key,
    required this.detail,
    required this.onClose,
  });

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
                  color: const Color(0xFFDC2626), // Match screenshot red
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: AirMenuTextStyle.headingH4.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.address} • ${detail.floors} • ${detail.totalRooms}',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rooms Summary (Left)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rooms Summary',
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...detail.rooms.map((room) => _buildRoomRow(room)),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Orders Trend (Right)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Orders Trend',
                          style: AirMenuTextStyle.normal.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Optional filter or legend
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mock Chart
                    SizedBox(
                      height: 200,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _TrendChartPainter(points: detail.orderTrend),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // X-Axis labels mocked
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: detail.orderTrend
                          .map(
                            (p) => Text(
                              p.day,
                              style: AirMenuTextStyle.small.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 10,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomRow(RoomSummary room) {
    Color statusColor;
    Color statusBgColor;
    Color iconBgColor = const Color(0xFFF3F4F6); // Default grey
    IconData icon = Icons.bed_rounded;
    Color iconColor = const Color(0xFF6B7280); // Default grey

    switch (room.status) {
      case 'occupied':
        statusColor = const Color(0xFF166534);
        statusBgColor = const Color(0xFFDCFCE7);
        iconBgColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        break;
      case 'vacant':
        statusColor = const Color(0xFF374151);
        statusBgColor = const Color(0xFFF3F4F6);
        iconBgColor = const Color(0xFFECFDF5);
        iconColor = const Color(0xFF059669);
        break;
      case 'cleaning':
        statusColor = const Color(0xFFB45309);
        statusBgColor = const Color(0xFFFEF3C7);
        iconBgColor = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFEA580C);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
    }

    // Screenshot logic:
    // Occupied rooms have Red Icon bg.

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: const Color(0xFFF3F4F6)), // Optional border
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12), // Rounded square
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomNumber,
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  room.floor,
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${room.orders} orders',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      room.status,
                      style: AirMenuTextStyle.small.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<OrderTrendPoint> points;
  _TrendChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFDC2626).withOpacity(0.2),
          const Color(0xFFDC2626).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path(); // For gradient fill

    final double stepX = size.width / (points.length - 1);
    final double maxVal =
        points.map((e) => e.orders.toDouble()).reduce((a, b) => a > b ? a : b) *
        1.2; // Add padding

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y =
          size.height - ((points[i].orders / maxVal) * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height); // Start at bottom left
        fillPath.lineTo(x, y);
      } else {
        // Cubic bezier for smooth curve
        final double prevX = (i - 1) * stepX;
        final double prevY =
            size.height - ((points[i - 1].orders / maxVal) * size.height);

        final double controlX1 = prevX + stepX / 2;
        final double controlY1 = prevY;
        final double controlX2 = x - stepX / 2;
        final double controlY2 = y;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }

      if (i == points.length - 1) {
        fillPath.lineTo(x, size.height); // Close at bottom right
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
