import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 0,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white, // Standard white background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AirMenuColors.primary.shade9,
            width: 2,
          ), // Subtle red tint border for theme
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logout',
              style: AirMenuTextStyle.headingH3.copyWith(
                color: AirMenuColors.primary, // Red Title to match theme
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to logout?',
              style: AirMenuTextStyle.normal.copyWith(
                color: const Color(0xFF4B5563), // Neutral dark grey
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    foregroundColor: const Color(0xFF6B7280), // Grey for Cancel
                  ),
                  child: Text(
                    'Cancel',
                    style: AirMenuTextStyle.normal.medium500().copyWith(
                      color: const Color(0xFF6B7280), // Grey text
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    foregroundColor: AirMenuColors.primary, // Red for Logout
                  ),
                  child: Text(
                    'Logout',
                    style: AirMenuTextStyle.normal.bold600().copyWith(
                      color: AirMenuColors.primary, // Red text
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
