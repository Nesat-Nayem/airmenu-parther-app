import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import '../bloc/tables_bloc.dart';
import 'table_card.dart';

/// Stats Row — Lovable glass tiles; tap filters by status.
class TablesStatsRow extends StatelessWidget {
  final List<TableModel> tables;

  const TablesStatsRow({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    int vacant = 0;
    int occupied = 0;
    int reserved = 0;
    int cleaning = 0;

    for (final table in tables) {
      switch (table.status) {
        case TableStatus.vacant:
          vacant++;
          break;
        case TableStatus.occupied:
          occupied++;
          break;
        case TableStatus.reserved:
          reserved++;
          break;
        case TableStatus.cleaning:
          cleaning++;
          break;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 640;
        final tiles = [
          _StatTileData('Vacant', vacant, const Color(0xFF22C55E), TableStatus.vacant),
          _StatTileData('Occupied', occupied, TableCardLayout.accent, TableStatus.occupied),
          _StatTileData('Reserved', reserved, const Color(0xFFF59E0B), TableStatus.reserved),
          _StatTileData('Cleaning', cleaning, const Color(0xFF6B7280), TableStatus.cleaning),
        ];

        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatTile(data: tiles[i])),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(data: tiles[i + 1])),
                  ],
                ),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: _StatTile(data: tiles[i])),
            ],
          ],
        );
      },
    );
  }
}

class _StatTileData {
  final String title;
  final int count;
  final Color color;
  final TableStatus status;

  const _StatTileData(this.title, this.count, this.color, this.status);
}

class _StatTile extends StatefulWidget {
  final _StatTileData data;

  const _StatTile({required this.data});

  @override
  State<_StatTile> createState() => _StatTileState();
}

class _StatTileState extends State<_StatTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final state = context.watch<TablesBloc>().state;
    final isActive = state.statusFilter == data.status;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: () {
          final bloc = context.read<TablesBloc>();
          final current = bloc.state;
          bloc.add(
            FilterTables(
              searchQuery: current.searchQuery,
              zoneFilter: current.zoneFilter,
              statusFilter:
                  current.statusFilter == data.status ? null : data.status,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? data.color.withValues(alpha: 0.45)
                  : (_hovered
                      ? data.color.withValues(alpha: 0.28)
                      : TableCardLayout.idleBorder),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (_hovered || isActive)
                    ? data.color.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: (_hovered || isActive) ? 14 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.title,
                    style: GoogleFonts.sora(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: TableCardLayout.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.count.toString(),
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: TableCardLayout.foreground,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for stats row while tables load.
class TablesStatsSkeleton extends StatelessWidget {
  const TablesStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 14 : 0),
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TableCardLayout.idleBorder),
              ),
            ),
          ),
        );
      }),
    );
  }
}
