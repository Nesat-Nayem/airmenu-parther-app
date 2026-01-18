import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';

class PolicyActionButtons extends StatelessWidget {
  final VoidCallback onGenerateWithAI;
  final VoidCallback onSaveChanges;
  final bool isGenerating;
  final bool isSaving;
  final bool isVertical;

  const PolicyActionButtons({
    super.key,
    required this.onGenerateWithAI,
    required this.onSaveChanges,
    this.isGenerating = false,
    this.isSaving = false,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final generateButton = SizedBox(
      width: isVertical ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isGenerating || isSaving ? null : onGenerateWithAI,
        icon: isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome, size: 18),
        label: Text(isGenerating ? 'Generating...' : 'Generate with AI'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0), // Purple color
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    final saveButton = SizedBox(
      width: isVertical ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isGenerating || isSaving ? null : onSaveChanges,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save, size: 18),
        label: Text(isSaving ? 'Saving...' : 'Save Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AirMenuColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [generateButton, const SizedBox(height: 12), saveButton],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [generateButton, const SizedBox(width: 12), saveButton],
    );
  }
}
