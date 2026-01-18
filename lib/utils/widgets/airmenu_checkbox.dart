import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Reusable checkbox widget
class AirMenuCheckbox extends StatelessWidget {
  const AirMenuCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final void Function(bool?)? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final checkbox = Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AirMenuColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );

    if (label == null) {
      return checkbox;
    }

    return InkWell(
      onTap: enabled
          ? () => onChanged?.call(!value)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkbox,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label!,
                style: AirMenuTextStyle.normal.copyWith(
                  color: enabled
                      ? AirMenuColors.black
                      : AirMenuColors.secondary.shade8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

