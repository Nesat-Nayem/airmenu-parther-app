import 'package:flutter/material.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/hotel_models.dart';

class HotelListTable extends StatelessWidget {
  final List<Hotel> hotels;
  final Function(String) onView;

  const HotelListTable({super.key, required this.hotels, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'HOTEL',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ROOMS',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ROOM SERVICE',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'LAUNDRY',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SLA',
                    style: AirMenuTextStyle.small.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ACTION',
                      style: AirMenuTextStyle.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Data Rows
          ...hotels.map((hotel) => _buildRow(hotel)),
        ],
      ),
    );
  }

  Widget _buildRow(Hotel hotel) {
    return InkWell(
      onTap: () => onView(hotel.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: AirMenuTextStyle.normal.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        hotel.address,
                        style: AirMenuTextStyle.small.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hotel.rooms,
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hotel.roomServiceOrders.toString(),
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                hotel.laundryRequests.toString(),
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${hotel.sla}%',
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: AirMenuTextStyle.small.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xFF374151),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
