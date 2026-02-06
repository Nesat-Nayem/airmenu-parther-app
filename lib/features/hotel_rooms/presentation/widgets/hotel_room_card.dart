import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';

class HotelRoomCard extends StatefulWidget {
  final HotelRoom room;
  final bool isSelected;
  final VoidCallback onTap;

  const HotelRoomCard({
    super.key,
    required this.room,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<HotelRoomCard> createState() => _HotelRoomCardState();
}

class _HotelRoomCardState extends State<HotelRoomCard> {
  bool _isHovered = false;

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.occupied:
        return Colors.green.shade100;
      case RoomStatus.vacant:
        return Colors.grey.shade200;
      case RoomStatus.cleaning:
        return Colors.orange.shade100;
    }
  }

  Color _getStatusTextColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.occupied:
        return Colors.green.shade800;
      case RoomStatus.vacant:
        return Colors.grey.shade700;
      case RoomStatus.cleaning:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered || widget.isSelected
                  ? AirMenuColors.primary
                  : Colors.transparent,
              width: _isHovered || widget.isSelected ? 1.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  _isHovered || widget.isSelected ? 0.08 : 0.04,
                ),
                blurRadius: _isHovered || widget.isSelected ? 24 : 20,
                offset: _isHovered || widget.isSelected
                    ? const Offset(0, 8)
                    : const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Room ${widget.room.roomNumber}',
                    style: AirMenuTextStyle.large.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (widget.room.ordersCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AirMenuColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.room.ordersCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.room.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getStatusTextColor(widget.room.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.room.status.name.toLowerCase(),
                      style: TextStyle(
                        color: _getStatusTextColor(widget.room.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (widget.room.status != RoomStatus.vacant) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.room.occupantName ?? 'Unknown',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: AirMenuColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  '${widget.room.ordersCount} orders today',
                  style: AirMenuTextStyle.small.copyWith(
                    color: AirMenuColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.room.slaScore > 0)
                  Text(
                    'SLA: ${widget.room.slaScore.toInt()}%',
                    style: AirMenuTextStyle.small.copyWith(
                      color: widget.room.slaScore > 90
                          ? Colors.green
                          : (widget.room.slaScore > 75
                                ? Colors.orange
                                : Colors.red),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ] else ...[
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
