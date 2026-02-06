import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/theatre_models.dart';

class TheatreListTable extends StatelessWidget {
  final List<Theatre> theatres;
  final Function(String id) onView;

  const TheatreListTable({
    super.key,
    required this.theatres,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(2.5), // Theatre
          1: FlexColumnWidth(1.4), // City
          2: FlexColumnWidth(1.8), // Restaurant
          3: FlexColumnWidth(0.8), // Seats
          4: FlexColumnWidth(0.8), // Intervals
          5: FlexColumnWidth(1.0), // Orders
          6: FlexColumnWidth(1.0), // Peak
          7: FlexColumnWidth(0.8), // SLA
          8: FlexColumnWidth(1.2), // Action
        },
        children: [
          _buildHeaderRow(),
          ...theatres.map((theatre) => _buildRow(theatre)),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children:
          [
                'THEATRE',
                'CITY',
                'RESTAURANT',
                'SEATS',
                'INTERVALS',
                'ORDERS',
                'PEAK',
                'SLA',
                'ACTION',
              ]
              .map(
                (title) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Text(
                    title,
                    style: AirMenuTextStyle.caption.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  TableRow _buildRow(Theatre theatre) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      children: [
        _buildCell(
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie_filter_outlined,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theatre.name,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${theatre.screens} screens',
                      style: AirMenuTextStyle.small.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildCell(
          Text(
            theatre.city,
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        _buildCell(
          Text(
            theatre.restaurant,
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildCell(
          Text(theatre.seats.toString(), style: AirMenuTextStyle.normal),
        ),
        _buildCell(Text(theatre.intervals, style: AirMenuTextStyle.normal)),
        _buildCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theatre.orders.toString(),
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${theatre.revenue.toStringAsFixed(0)}',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _buildCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(theatre.peakTime, style: AirMenuTextStyle.normal),
              Text(
                'PM',
                style: AirMenuTextStyle.small.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        _buildCell(
          Text(
            '${theatre.sla}%',
            style: AirMenuTextStyle.normal.copyWith(
              color: const Color(0xFF166534),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _buildCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () => onView(theatre.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ), // Reduced padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View',
                          style: AirMenuTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Reduced from 24
      child: child,
    );
  }
}
