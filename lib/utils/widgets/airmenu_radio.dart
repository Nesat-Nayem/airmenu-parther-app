import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Reusable radio button widget
class AirMenuRadio<T> extends StatelessWidget {
  const AirMenuRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final void Function(T?)? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radio = Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
      activeColor: AirMenuColors.primary,
    );

    if (label == null) {
      return radio;
    }

    return InkWell(
      onTap: enabled
          ? () => onChanged?.call(value)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            radio,
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

