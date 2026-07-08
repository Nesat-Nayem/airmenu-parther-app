import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Status Tile - Kitchen Panel Stats Card
/// Matches Lovable KDS mockup with circular icon, large count, and comparison badge
class PremiumStatusTile extends StatefulWidget {
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
  final String? displayValue; // For string-based values like "18 min"

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
    this.displayValue,
  });

  @override
  State<PremiumStatusTile> createState() => _PremiumStatusTileState();
}

class _PremiumStatusTileState extends State<PremiumStatusTile> {
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  @override
  void dispose() {
    _hovered.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hovered.value != value) {
        _hovered.value = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _hovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCircularIcon(hovered),
                      if (widget.comparisonBadge != null)
                        Flexible(child: _buildComparisonBadge()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.displayValue ?? '${widget.count}',
                        style: GoogleFonts.sora(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                          color: hovered
                              ? AirMenuColors.primary
                              : const Color(0xFF111827),
                        ),
                      ),
                      if (widget.showMinSuffix &&
                          widget.displayValue == null) ...[
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
                  Text(
                    widget.label,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
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

  Widget _buildCircularIcon(bool hovered) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.iconBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.iconColor.withValues(alpha: hovered ? 0.22 : 0.1),
        ),
        boxShadow: hovered
            ? [
                BoxShadow(
                  color: widget.iconColor.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Icon(widget.icon, size: 22, color: widget.iconColor),
    );
  }

  Widget _buildComparisonBadge() {
    const greenBg = Color(0xFFDCFCE7);
    const greenText = Color(0xFF16A34A);
    const redBg = Color(0xFFFEE2E2);
    const redText = Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isPositiveComparison ? greenBg : redBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isPositiveComparison
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            size: 14,
            color: widget.isPositiveComparison ? greenText : redText,
          ),
          const SizedBox(width: 4),
          Text(
            widget.comparisonBadge!,
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isPositiveComparison ? greenText : redText,
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
          // Use smaller maxExtent for narrow screens (mobile)
          final double maxExtent = width < 400 ? 150.0 : 240.0;
          int crossAxisCount = (width / maxExtent).floor();
          if (crossAxisCount < 1) crossAxisCount = 1;
          if (crossAxisCount > tiles.length) crossAxisCount = tiles.length;

          // Gap between tiles
          final double gap = width < 400 ? 10.0 : 16.0;
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
