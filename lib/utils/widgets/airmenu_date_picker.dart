import 'package:airmenuai_partner_app/utils/widgets/airmenu_text_field.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:flutter/material.dart';

/// Reusable date picker widget
class AirMenuDatePicker extends StatelessWidget {
  const AirMenuDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label,
    this.hint = 'Select date',
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String? label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AirMenuColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: selectedDate != null
          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
          : null,
    );

    return GestureDetector(
      onTap: enabled ? () => _selectDate(context) : null,
      child: AbsorbPointer(
        child: AirMenuTextField(
          label: label,
          hint: hint,
          enabled: enabled,
          controller: controller,
          suffixIcon: Icon(
            Icons.calendar_today,
            color: AirMenuColors.secondary.shade5,
          ),
        ),
      ),
    );
  }
}
