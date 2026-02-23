import 'package:airmenuai_partner_app/features/menu/presentation/widgets/ai_description_generator_dialog.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';

class AddEditMenuItemDialog extends StatelessWidget {
  const AddEditMenuItemDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: 800,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Item', // Dynamic title based on mode
                  style: AirMenuTextStyle.headingH3.bold700(),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TextInputField(
                      label: 'Item Name *',
                      hint: 'e.g., Butter Chicken',
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: const [
                        Expanded(
                          child: _DropdownField(
                            label: 'Category *',
                            value: 'Main Course',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _TextInputField(
                            label: 'Price (₹) *',
                            hint: '350',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Description',
                          style: AirMenuTextStyle.normal.bold600(),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  const AiDescriptionGeneratorDialog(),
                            );
                          },
                          icon: const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AirMenuColors.primaryRed,
                          ),
                          label: Text(
                            'AI Suggest',
                            style: AirMenuTextStyle.small.bold700().withColor(
                              AirMenuColors.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AirMenuColors.borderDefault),
                      ),
                      child: TextField(
                        maxLines: null,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Describe the dish...',
                          hintStyle: AirMenuTextStyle.normal
                              .medium500()
                              .withColor(AirMenuColors.textTertiary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Image Upload
                    Text('Image', style: AirMenuTextStyle.normal.bold600()),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AirMenuColors.primaryRedLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AirMenuColors.primaryRed.withOpacity(0.2),
                          style: BorderStyle.solid,
                        ), // Dashed border usually requires custom painter or package
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 32,
                            color: AirMenuColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Click to upload or drag and drop',
                            style: AirMenuTextStyle.normal
                                .medium500()
                                .withColor(AirMenuColors.textSecondary),
                          ),
                          Text(
                            'PNG, JPG up to 5MB',
                            style: AirMenuTextStyle.small.medium500().withColor(
                              AirMenuColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(
                          child: _DropdownField(
                            label: 'Type',
                            value: 'Vegetarian',
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _DropdownField(
                            label: 'Tax Category',
                            value: 'Food - 5%',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    // Footer Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '+ Add Variant',
                            style: AirMenuTextStyle.normal.bold600().withColor(
                              AirMenuColors.textPrimary,
                            ),
                          ),
                        ),
                        // Save Buttons
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                foregroundColor: AirMenuColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Save Item'),
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
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final String label;
  final String hint;
  const _TextInputField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.normal.bold600()),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AirMenuTextStyle.normal.medium500().withColor(
              AirMenuColors.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AirMenuColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AirMenuColors.borderDefault),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  const _DropdownField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.normal.bold600()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AirMenuColors.borderDefault),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: [DropdownMenuItem(value: value, child: Text(value))],
            onChanged: (val) {},
          ),
        ),
      ],
    );
  }
}
