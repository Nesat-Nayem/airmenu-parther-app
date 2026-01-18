import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';

/// Stats Row for Tables & QR page
/// Shows count tiles for Vacant, Occupied, Reserved, Cleaning
class TablesStatsRow extends StatelessWidget {
  final List<TableModel> tables;

  const TablesStatsRow({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    int vacant = 0;
    int occupied = 0;
    int reserved = 0;
    int cleaning = 0;

    for (var table in tables) {
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

    return Row(
      children: [
        _buildStatTile(
          context,
          title: 'Vacant',
          count: vacant,
          color: const Color(0xFF22C55E), // Green-500
        ),
        const SizedBox(width: 16),
        _buildStatTile(
          context,
          title: 'Occupied',
          count: occupied,
          color: const Color(0xFFEF4444), // Red-500
        ),
        const SizedBox(width: 16),
        _buildStatTile(
          context,
          title: 'Reserved',
          count: reserved,
          color: const Color(0xFFF59E0B), // Amber-500
        ),
        const SizedBox(width: 16),
        _buildStatTile(
          context,
          title: 'Cleaning',
          count: cleaning,
          color: const Color(0xFF6B7280), // Gray-500
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
