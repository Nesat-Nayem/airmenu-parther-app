import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/theatre_models.dart';

class TheatreIntervalsTab extends StatelessWidget {
  final List<TheatreInterval> intervals;

  const TheatreIntervalsTab({super.key, required this.intervals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Intervals',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Manage Shows',
                style: AirMenuTextStyle.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...intervals.map((interval) => _buildIntervalCard(interval)),
      ],
    );
  }

  Widget _buildIntervalCard(TheatreInterval interval) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors
            .white, // In screenshot it's white or very light grey? Assuming white on white bg? Or card.
        // Actually detail panel is white, so maybe just simple rows or bordered.
        // Screenshot shows them as "rows" with lots of white space.
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.access_time, color: Color(0xFFDC2626)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    interval.time,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    interval.screen,
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              Text(
                interval.movie,
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStat(interval.orders.toString(), 'Orders'),
          const SizedBox(width: 24),
          _buildStat(interval.pending.toString(), 'Pending', isWarning: true),
          const SizedBox(width: 24),
          _buildStat(interval.ads.toString(), 'Ads'),
          const SizedBox(width: 32),

          if (interval.status == 'Off')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF6B7280)),
                  const SizedBox(width: 6),
                  Text(
                    'Off',
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF166534)),
                  const SizedBox(width: 6),
                  Text(
                    'Prebooking On',
                    style: AirMenuTextStyle.small.copyWith(
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  'Ads',
                  style: AirMenuTextStyle.small.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'View Orders',
            style: AirMenuTextStyle.small.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, {bool isWarning = false}) {
    return Column(
      children: [
        Text(
          value,
          style: AirMenuTextStyle.headingH4.copyWith(
            fontWeight: FontWeight.bold,
            color: isWarning
                ? const Color(0xFFF59E0B)
                : const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
