import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tables_bloc.dart';
import 'table_card.dart';

class TablesToolbar extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool>? onViewModeChanged;

  const TablesToolbar({
    super.key,
    this.isGridView = true,
    this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TablesBloc, TablesState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wrap = constraints.maxWidth < 720;
            final search = _buildSearch(context, state);
            final zone = Builder(
              builder: (context) {
                final zoneItems = ['All Zones', ...state.zoneNames];
                final currentValue =
                    (state.zoneFilter != null &&
                        zoneItems.contains(state.zoneFilter))
                    ? state.zoneFilter!
                    : 'All Zones';
                return _buildDropdown(
                  value: currentValue,
                  items: zoneItems,
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
                );
              },
            );
            final status = _buildDropdown(
              value: _statusToString(state.statusFilter) ?? 'All Status',
              items: const [
                'All Status',
                'Vacant',
                'Occupied',
                'Reserved',
                'Cleaning',
              ],
              icon: Icons.filter_list_rounded,
              onChanged: (value) {
                context.read<TablesBloc>().add(
                  FilterTables(
                    searchQuery: state.searchQuery,
                    zoneFilter: state.zoneFilter,
                    statusFilter: _stringToStatus(value),
                  ),
                );
              },
            );
            final viewToggle = onViewModeChanged == null
                ? const SizedBox.shrink()
                : _ViewModeToggle(
                    isGrid: isGridView,
                    onChanged: onViewModeChanged!,
                  );

            if (wrap) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: zone),
                      const SizedBox(width: 10),
                      Expanded(child: status),
                      if (onViewModeChanged != null) ...[
                        const SizedBox(width: 10),
                        viewToggle,
                      ],
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: search),
                const SizedBox(width: 12),
                zone,
                const SizedBox(width: 12),
                status,
                if (onViewModeChanged != null) ...[
                  const SizedBox(width: 12),
                  viewToggle,
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearch(BuildContext context, TablesState state) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TableCardLayout.idleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        style: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: TableCardLayout.foreground,
        ),
        decoration: InputDecoration(
          hintText: 'Search tables...',
          hintStyle: GoogleFonts.sora(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TableCardLayout.idleBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Colors.grey,
          ),
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TableCardLayout.foreground,
          ),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.grey.shade500),
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

class _ViewModeToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;

  const _ViewModeToggle({required this.isGrid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(
            icon: Icons.grid_view_rounded,
            selected: isGrid,
            onTap: () => onChanged(true),
          ),
          _seg(
            icon: Icons.view_list_rounded,
            selected: !isGrid,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _seg({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? TableCardLayout.accent.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(
            icon,
            size: 18,
            color: selected ? TableCardLayout.accent : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
