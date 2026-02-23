import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AiDescriptionGeneratorDialog extends StatelessWidget {
  const AiDescriptionGeneratorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AirMenuColors.primaryRed,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Description Generator',
                      style: AirMenuTextStyle.headingH4.bold700(),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Generate an engaging description for your menu item using AI.',
              style: AirMenuTextStyle.normal.medium500().withColor(
                AirMenuColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                // Generate Logic
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generate Description'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: AirMenuColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 4,
                shadowColor: AirMenuColors.primaryRed.withOpacity(0.4),
              ),
            ),

            const SizedBox(height: 32),

            // Placeholder for generated content or image upload prompt from screenshot which overlaps
            // Based on screenshot, it seems to overlap with image upload in one view layout,
            // but here as a separated dialog we focus on the text generation aspect
            // OR the screenshot shows the "Upload Menu Image" for Import.
            // The User Request "popup when click on ai suggest" shows "AI Description Generator".
            // The other screenshot shows "AI Menu Creator" for import.
            // This file is for the Suggest.
          ],
        ),
      ),
    );
  }
}
