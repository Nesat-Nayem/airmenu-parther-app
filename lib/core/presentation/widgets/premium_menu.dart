import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// A Premium styled PopupMenuButton that matches the Tool menu design.
/// - Rounded Corners (16px)
/// - White Background with Shadow
/// - Premium Hover Effects
class PremiumPopupMenuButton<T> extends StatelessWidget {
  final Widget child;
  final List<PremiumPopupMenuItem<T>> items;
  final void Function(T)? onSelected;
  final Offset offset;
  final double? width;

  const PremiumPopupMenuButton({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
    this.offset = const Offset(0, 4),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent, // Disable default grey hover
        splashColor: const Color(
          0xFFFEE2E2,
        ).withOpacity(0.5), // Subtle red ripple
        highlightColor: const Color(0xFFFEF2F2), // Subtle red highlight
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.15),
          surfaceTintColor: Colors.white, // Ensure no heavy tint
        ),
      ),
      child: PopupMenuButton<T>(
        onSelected: onSelected,
        offset: offset,
        position: PopupMenuPosition.under,
        constraints: width != null
            ? BoxConstraints.tightFor(width: width)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            height: 40, // Reduced height for compactness
            padding: EdgeInsets.zero,
            child: _PremiumMenuItemContent(
              icon: item.icon,
              label: item.label,
              isDestructive: item.isDestructive,
              hasDivider: item.hasDivider,
            ),
          );
        }).toList(),
        child: child,
      ),
    );
  }
}

class PremiumPopupMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final bool hasDivider;

  PremiumPopupMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.hasDivider = false,
  });
}

class _PremiumMenuItemContent extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool isDestructive;
  final bool hasDivider;

  const _PremiumMenuItemContent({
    this.icon,
    required this.label,
    this.isDestructive = false,
    this.hasDivider = false,
  });

  @override
  State<_PremiumMenuItemContent> createState() =>
      _PremiumMenuItemContentState();
}

class _PremiumMenuItemContentState extends State<_PremiumMenuItemContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF374151);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.hasDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ), // Reduced padding
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFFEF2F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(
                8,
              ), // Inner radius for hover item
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: _isHovered
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  widget.label,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    _isHovered ? const Color(0xFFDC2626) : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A Premium Dropdown Field that mimics a Select input but uses the Popup Menu.
class PremiumDropdownField<T> extends StatelessWidget {
  final String label;
  final String displayValue;
  final T? selectedValue;
  final List<PremiumPopupMenuItem<T>> items;
  final void Function(T) onSelected;
  final bool isEnabled;
  final bool hasError;
  final double? width;

  const PremiumDropdownField({
    super.key,
    required this.label,
    required this.displayValue,
    required this.items,
    required this.onSelected,
    this.selectedValue,
    this.isEnabled = true,
    this.hasError = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AirMenuTextStyle.small.bold600().withColor(
              const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: !isEnabled,
            child: PremiumPopupMenuButton<T>(
              onSelected: onSelected,
              width: width,
              items: items,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: hasError
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasError
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayValue,
                      style: AirMenuTextStyle.normal.medium500().withColor(
                        const Color(0xFF111827),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
