import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class TheatreSeatMapTab extends StatelessWidget {
  const TheatreSeatMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Seat Ordering Status',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildLegendItem(const Color(0xFF22C55E), 'No Order'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFFACC15), 'Pending'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFEF4444), 'Ordered'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Screen Indicator
        Center(
          child: Container(
            width: 600,
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[400]!,
                  Colors.grey[200]!,
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'SCREEN',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Seat Grid
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: 'ABCDEFGH'.split('').map((rowLabel) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        rowLabel,
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 24),
                      ...List.generate(12, (index) {
                        // Mock Pattern from screenshot
                        // Some gaps in middle
                        if (index == 4 || index == 8) {
                          return const SizedBox(width: 24);
                        }

                        // Randomize colors for demo based on index/row
                        Color color = const Color(
                          0xFF22C55E,
                        ); // Green (No Order)
                        if ((rowLabel.codeUnitAt(0) + index) % 5 == 0)
                          color = const Color(0xFFEF4444); // Red
                        if ((rowLabel.codeUnitAt(0) + index) % 7 == 0)
                          color = const Color(0xFFFACC15); // Yellow

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 16),
                      Text(
                        rowLabel,
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
