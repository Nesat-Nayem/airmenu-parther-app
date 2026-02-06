import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/location_form_cubit.dart';
import 'package:airmenuai_partner_app/core/presentation/widgets/premium_menu.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class AddLocationFormDialog extends StatelessWidget {
  const AddLocationFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationFormCubit(),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Location',
                  style: AirMenuTextStyle.headingH4.withColor(
                    const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _TextField(
              label: 'Location Name *',
              hint: 'e.g., Downtown Branch',
            ),
            const SizedBox(height: 16),

            BlocBuilder<LocationFormCubit, LocationFormState>(
              builder: (context, state) {
                return PremiumDropdownField<String>(
                  label: 'Type *',
                  displayValue: state.addLocationType,
                  selectedValue: state.addLocationType,
                  width: 452, // Fixed width to match text fields
                  items: [
                    PremiumPopupMenuItem(
                      value: 'Branch / Outlet',
                      label: 'Branch / Outlet',
                    ),
                    PremiumPopupMenuItem(
                      value: 'Warehouse',
                      label: 'Warehouse',
                    ),
                    PremiumPopupMenuItem(value: 'Kitchen', label: 'Kitchen'),
                    PremiumPopupMenuItem(
                      value: 'Storage Unit',
                      label: 'Storage Unit',
                    ),
                  ],
                  onSelected: (val) =>
                      context.read<LocationFormCubit>().setAddLocationType(val),
                );
              },
            ),
            const SizedBox(height: 16),

            const _TextField(label: 'Address *', hint: 'Full address'),
            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(
                  child: _TextField(label: 'Manager', hint: 'Manager name'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _TextField(label: 'Phone', hint: '+91 XXXXX XXXXX'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    foregroundColor: const Color(0xFF374151),
                  ),
                  child: Text(
                    'Cancel',
                    style: AirMenuTextStyle.normal.bold600(),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<LocationFormCubit, LocationFormState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () async {
                              await context
                                  .read<LocationFormCubit>()
                                  .submitAddLocation();
                              if (context.mounted) Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InventoryColors.primaryRed,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: InventoryColors.primaryRed.withOpacity(
                          0.4,
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Add Location',
                              style: AirMenuTextStyle.normal
                                  .bold600()
                                  .withColor(Colors.white),
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;

  const _TextField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.bold600().withColor(
            const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: TextField(
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: AirMenuTextStyle.normal.medium500().withColor(
                const Color(0xFF9CA3AF),
              ),
            ),
            style: AirMenuTextStyle.normal.medium500(),
          ),
        ),
      ],
    );
  }
}
