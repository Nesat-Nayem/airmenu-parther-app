import 'package:airmenuai_partner_app/utils/widgets/airmenu_button.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable file picker widget
class AirMenuFilePicker extends StatelessWidget {
  const AirMenuFilePicker({
    super.key,
    required this.onFileSelected,
    this.label,
    this.allowedExtensions,
    this.maxSizeMB,
  });

  final void Function(String path) onFileSelected;
  final String? label;
  final List<String>? allowedExtensions;
  final double? maxSizeMB;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      onFileSelected(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AirMenuTextStyle.subheadingH5),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            AirMenuButton(
              label: 'Camera',
              onPressed: () => _pickImage(context, ImageSource.camera),
              variant: AirMenuButtonVariant.outline,
              icon: const Icon(Icons.camera_alt, size: 20),
            ),
            const SizedBox(width: 8),
            AirMenuButton(
              label: 'Gallery',
              onPressed: () => _pickImage(context, ImageSource.gallery),
              variant: AirMenuButtonVariant.outline,
              icon: const Icon(Icons.photo_library, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
