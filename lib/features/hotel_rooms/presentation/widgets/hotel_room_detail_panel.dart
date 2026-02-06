import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';

class HotelRoomInfoCard extends StatefulWidget {
  final HotelRoom room;
  final VoidCallback onClose;

  const HotelRoomInfoCard({
    super.key,
    required this.room,
    required this.onClose,
  });

  @override
  State<HotelRoomInfoCard> createState() => _HotelRoomInfoCardState();
}

class _HotelRoomInfoCardState extends State<HotelRoomInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.room.status == RoomStatus.vacant) {
      return _buildVacantState();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 24 : 20,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${widget.room.roomNumber}',
                  style: AirMenuTextStyle.large.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              Icons.person_outline,
              'Guest',
              widget.room.occupantName ?? 'Unknown',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today_outlined, 'Check-in', 'Dec 10'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today_outlined, 'Check-out', 'Dec 15'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SLA Score',
                  style: TextStyle(color: AirMenuColors.textSecondary),
                ),
                Text(
                  '${widget.room.slaScore.toInt()}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
          ],
        ),
      ),
    );
  }

  Widget _buildVacantState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(child: Text("Select an occupied room")),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AirMenuColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: AirMenuColors.textSecondary),
            ),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class HotelRoomTabsCard extends StatefulWidget {
  final HotelRoom room;
  final List<RoomOrder> orders;

  const HotelRoomTabsCard({
    super.key,
    required this.room,
    required this.orders,
  });

  @override
  State<HotelRoomTabsCard> createState() => _HotelRoomTabsCardState();
}

class _HotelRoomTabsCardState extends State<HotelRoomTabsCard> {
  String _selectedTab = 'Food';
  bool _isHovered = false;

  List<RoomOrder> get filteredOrders {
    return widget.orders.where((order) {
      return order.description.toLowerCase() == _selectedTab.toLowerCase() ||
          order.description.toLowerCase().contains(_selectedTab.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room.status == RoomStatus.vacant) return const SizedBox();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 24 : 20,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tabs
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTab('Food'),
                    const SizedBox(width: 8),
                    _buildTab('Laundry'),
                    const SizedBox(width: 8),
                    _buildTab('Clean'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Room Specific Orders (Filtered by Tab)
            if (filteredOrders.isNotEmpty)
              ...filteredOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOrderCard(order),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(32.0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 32,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No $_selectedTab orders",
                      style: const TextStyle(
                        color: AirMenuColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AirMenuColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            color: isSelected ? Colors.white : AirMenuColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(RoomOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.name.toLowerCase(),
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.title),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 min ago',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (order.amount > 0)
                Text(
                  '₹${order.amount.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          SizedBox(height: 8),
          if (order.status == RoomOrderState.pending ||
              order.status == RoomOrderState.preparing)
            SizedBox(
              height: 32,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Assign Staff'),
              ),
            ),
        ],
      ),
    );
  }
}
