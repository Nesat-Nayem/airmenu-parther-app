import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Status Tile - Kitchen Panel Stats Card
/// Matches Lovable KDS mockup with circular icon, large count, and comparison badge
class PremiumStatusTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final int count;
  final String label;
  final String? subtitle;
  final String? comparisonBadge;
  final bool isPositiveComparison;
  final VoidCallback? onTap;
  final bool showMinSuffix; // For "Avg Prep Time" to show "12 min"

  const PremiumStatusTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.count,
    required this.label,
    this.subtitle,
    this.comparisonBadge,
    this.isPositiveComparison = true,
    this.onTap,
    this.showMinSuffix = false,
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
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translate(0.0, hovered ? -2.0 : 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? AirMenuColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade100,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered
                        ? AirMenuColors.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: hovered ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Icon + Comparison Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCircularIcon(hovered),
                      if (comparisonBadge != null) _buildComparisonBadge(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Count with optional "min" suffix
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$count',
                        style: GoogleFonts.sora(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          color: hovered
                              ? AirMenuColors.primary
                              : const Color(0xFF111827),
                        ),
                      ),
                      if (showMinSuffix) ...[
                        const SizedBox(width: 4),
                        Text(
                          'min',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// Label
                  Text(
                    label,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  /// Subtitle (e.g., "vs yesterday")
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Circular icon container matching the reference design
  Widget _buildCircularIcon(bool hovered) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconBgColor,
        shape: BoxShape.circle,
        boxShadow: hovered
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: 22, color: iconColor),
    );
  }

  /// Comparison badge with trend icon
  Widget _buildComparisonBadge() {
    const greenBg = Color(0xFFDCFCE7);
    const greenText = Color(0xFF16A34A);
    const redBg = Color(0xFFFEE2E2);
    const redText = Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPositiveComparison ? greenBg : redBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositiveComparison
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            size: 14,
            color: isPositiveComparison ? greenText : redText,
          ),
          const SizedBox(width: 4),
          Text(
            comparisonBadge!,
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositiveComparison ? greenText : redText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive Grid for Status Tiles
class StatusTilesGrid extends StatelessWidget {
  final List<PremiumStatusTile> tiles;
  final EdgeInsets padding;

  const StatusTilesGrid({
    super.key,
    required this.tiles,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Calculate columns for responsive layout
          const double maxExtent = 260.0;
          int crossAxisCount = (width / maxExtent).ceil();
          if (crossAxisCount < 1) crossAxisCount = 1;
          if (crossAxisCount > tiles.length) crossAxisCount = tiles.length;

          const double gap = 16.0;
          final tileWidth =
              (width - gap * (crossAxisCount - 1)) / crossAxisCount;

          final rows = <List<PremiumStatusTile>>[];
          for (var i = 0; i < tiles.length; i += crossAxisCount) {
            rows.add(tiles.skip(i).take(crossAxisCount).toList());
          }

          return Column(
            children: rows.map((row) {
              return Padding(
                padding: EdgeInsets.only(bottom: row != rows.last ? gap : 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: row.map((tile) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: tile != row.last ? gap : 0,
                        ),
                        child: SizedBox(width: tileWidth, child: tile),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Backward compatibility aliases
typedef StatusTile = PremiumStatusTile;
typedef StatusTilesRow = StatusTilesGrid;
