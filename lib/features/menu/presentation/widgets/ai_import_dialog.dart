import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AiMenuImportDialog extends StatelessWidget {
  const AiMenuImportDialog({super.key});

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
                      'AI Menu Creator',
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
            const SizedBox(height: 8),
            Text(
              'Upload a photo of your menu and let AI extract all items automatically',
              style: AirMenuTextStyle.normal.medium500().withColor(
                AirMenuColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AirMenuColors.primaryRedLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AirMenuColors.primaryRed.withOpacity(0.2),
                  width: 1.5,
                  style: BorderStyle.solid,
                ), // Dashed effect mock
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AirMenuColors.primaryRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 48,
                      color: AirMenuColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload Menu Image',
                    style: AirMenuTextStyle.headingH4.bold600(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a photo or upload an image of your physical menu',
                    style: AirMenuTextStyle.small.medium500().withColor(
                      AirMenuColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AirMenuColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: const BorderSide(
                              color: Colors.white,
                            ), // Shadow handles border effect visually in mockup
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Upload File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AirMenuColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
