import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Shared Report Page Layout - Consistent header and action bar
class ReportPageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const ReportPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(),
            _buildActionBar(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Removed inner header
                  child,
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AirMenuTextStyle.headingH3.bold700().withColor(
                  Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AirMenuTextStyle.small.withColor(Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          // Back Button
          HoverButton(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Back to Reports',
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Date Range Selector
          const DateRangeSelector(),
          const SizedBox(width: 12),
          // Export Buttons
          const ExportButton(label: 'Export PDF', isPrimary: true),
          const SizedBox(width: 12),
          const ExportButton(label: 'Export Excel', isPrimary: false),
        ],
      ),
    );
  }
}

/// Hover Card - Premium hover effect for stat cards
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final List<Color>? gradientColors;
  final Color? hoverBorderColor;
  final Color? hoverShadowColor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradientColors,
    this.hoverBorderColor,
    this.hoverShadowColor,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.gradientColors == null ? Colors.white : null,
            gradient: widget.gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors!,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: widget.child,
        ),
      );
    }

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors!,
                  )
                : null,
            color: widget.gradientColors == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? (widget.hoverBorderColor ??
                        AirMenuColors.primary.withOpacity(0.3))
                  : Colors.grey.shade100,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? (widget.hoverShadowColor ??
                          AirMenuColors.primary.withOpacity(0.12))
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 24 : 12,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Hover Button - Simple hover effect for buttons
class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverButton({super.key, required this.child, required this.onTap});

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: widget.child,
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovered
                ? AirMenuColors.primary.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Date Range Selector - Reusable date picker button
class DateRangeSelector extends StatefulWidget {
  const DateRangeSelector({super.key});

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? AirMenuColors.primary.withValues(alpha: 0.02)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'This Week',
              style: AirMenuTextStyle.small.withColor(Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}

/// Export Button - Reusable export button with hover effect
class ExportButton extends StatefulWidget {
  final String label;
  final bool isPrimary;

  const ExportButton({super.key, required this.label, required this.isPrimary});

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? (_isHovered ? Colors.grey.shade800 : Colors.grey.shade900)
              : (_isHovered ? Colors.grey.shade50 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: widget.isPrimary
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.download_rounded,
              size: 16,
              color: widget.isPrimary ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: AirMenuTextStyle.small.medium500().withColor(
                widget.isPrimary ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hover Table Row - Row with hover effect for data tables
class HoverTableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HoverTableRow({super.key, required this.child, this.onTap});

  @override
  State<HoverTableRow> createState() => _HoverTableRowState();
}

class _HoverTableRowState extends State<HoverTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered
                ? AirMenuColors.primary.withValues(alpha: 0.02)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: _isHovered
                    ? AirMenuColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
              ),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
