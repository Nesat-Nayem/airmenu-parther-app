import 'package:flutter/material.dart';

class HotelRoomFilterBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(int?) onFloorChanged;
  final Function(String?) onStatusChanged;
  final String? selectedStatus;
  final int? selectedFloor;

  const HotelRoomFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFloorChanged,
    required this.onStatusChanged,
    this.selectedStatus,
    this.selectedFloor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Floor Filter
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedFloor,
                hint: const Text('All Floors'),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Floors')),
                  DropdownMenuItem(value: 1, child: Text('Floor 1')),
                  DropdownMenuItem(value: 2, child: Text('Floor 2')),
                  DropdownMenuItem(value: 3, child: Text('Floor 3')),
                ],
                onChanged: onFloorChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Status Filter
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedStatus,
                hint: const Text('All Status'),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Status')),
                  DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
                  DropdownMenuItem(value: 'Vacant', child: Text('Vacant')),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                ],
                onChanged: onStatusChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
