import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tables_bloc.dart';

class TablesToolbar extends StatelessWidget {
  const TablesToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TablesBloc, TablesState>(
      builder: (context, state) {
        return Row(
          children: [
            // Search
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  onChanged: (value) {
                    context.read<TablesBloc>().add(
                      FilterTables(
                        searchQuery: value,
                        zoneFilter: state.zoneFilter,
                        statusFilter: state.statusFilter,
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search tables...',
                    hintStyle: GoogleFonts.sora(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Zone Filter
            _buildDropdown(
              value: state.zoneFilter ?? 'All Zones',
              items: ['All Zones', 'Indoor', 'Outdoor', 'Private'],
              icon: Icons.place_outlined,
              onChanged: (value) {
                context.read<TablesBloc>().add(
                  FilterTables(
                    searchQuery: state.searchQuery,
                    zoneFilter: value == 'All Zones' ? null : value,
                    statusFilter: state.statusFilter,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // Status Filter
            _buildDropdown(
              value: _statusToString(state.statusFilter) ?? 'All Status',
              items: [
                'All Status',
                'Vacant',
                'Occupied',
                'Reserved',
                'Cleaning',
              ],
              icon: Icons
                  .filter_list, // Fallback icon instead of layers_outlined if unavailable
              onChanged: (value) {
                context.read<TablesBloc>().add(
                  FilterTables(
                    searchQuery: state.searchQuery,
                    zoneFilter: state.zoneFilter,
                    statusFilter: _stringToStatus(value),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String? _statusToString(TableStatus? status) {
    if (status == null) return null;
    switch (status) {
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }

  TableStatus? _stringToStatus(String? value) {
    if (value == 'All Status') return null;
    switch (value) {
      case 'Vacant':
        return TableStatus.vacant;
      case 'Occupied':
        return TableStatus.occupied;
      case 'Reserved':
        return TableStatus.reserved;
      case 'Cleaning':
        return TableStatus.cleaning;
      default:
        return null;
    }
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Colors.grey,
          ),
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
