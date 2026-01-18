import 'package:airmenuai_partner_app/features/kitchen/config/kitchen_config.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Station filter tabs for Kitchen Panel - Pill-shaped chips
class StationFilterTabs extends StatelessWidget {
  final String selectedStation;
  final ValueChanged<String> onStationSelected;
  final List<KitchenTaskModel> tasks;

  /// Dynamic stations from API (optional, falls back to config if empty)
  final List<KitchenStationModel> stations;

  const StationFilterTabs({
    super.key,
    required this.selectedStation,
    required this.onStationSelected,
    this.tasks = const [],
    this.stations = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Use dynamic stations if available, otherwise fall back to config
    final stationNames = stations.isNotEmpty
        ? ['All', ...stations.map((s) => s.name)]
        : KitchenConfig.stations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stationNames.map((station) {
            final isActive = selectedStation == station;
            final count = _getStationCount(station);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterPill(
                label: station,
                count: count,
                isActive: isActive,
                onTap: () => onStationSelected(station),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getStationCount(String station) {
    if (station == 'All') {
      return tasks.where((t) {
        final status = t.status.toUpperCase();
        return status == 'QUEUED' || status == 'IN_PROGRESS';
      }).length;
    }
    return tasks.where((t) {
      if (t.stationName.toLowerCase() != station.toLowerCase()) return false;
      final status = t.status.toUpperCase();
      return status == 'QUEUED' || status == 'IN_PROGRESS';
    }).length;
  }
}

/// Pill-shaped filter chip matching reference design
class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDC2626)
                    : hovered
                    ? Colors.grey.shade200
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFDC2626)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : hovered
                          ? const Color(0xFF111827)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
