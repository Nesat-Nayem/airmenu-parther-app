import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

/// Reusable dropdown widget
class AirMenuDropdown<T> extends StatelessWidget {
  const AirMenuDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.enabled = true,
    this.itemBuilder,
  });

  final List<T> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? label;
  final String? hint;
  final bool enabled;
  final String Function(T)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AirMenuTextStyle.subheadingH5,
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemBuilder?.call(item) ?? item.toString(),
                style: AirMenuTextStyle.normal,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AirMenuTextStyle.smallHint,
            filled: true,
            fillColor: enabled ? Colors.white : AirMenuColors.secondary.shade9,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AirMenuColors.secondary.shade8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AirMenuColors.secondary.shade8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AirMenuColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AirMenuColors.secondary.shade8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AirMenuTextStyle.normal,
        ),
      ],
    );
  }
}

