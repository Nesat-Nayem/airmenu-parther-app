import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

/// Search field widget for dashboard
class DashboardSearchField extends StatelessWidget {
  final Function(String) onSearchChanged;
  final String hintText;
  final bool isMobile;

  const DashboardSearchField({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Search restaurants, orders, alerts...',
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AirMenuTextStyle.small.copyWith(
          color: const Color(0xFF9CA3AF),
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: Color(0xFF9CA3AF),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AirMenuColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 10 : 12,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
      ),
      style: AirMenuTextStyle.normal.copyWith(fontSize: isMobile ? 13 : 14),
    );
  }
}
