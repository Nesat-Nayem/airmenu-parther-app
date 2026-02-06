import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/location_form_cubit.dart';
import 'package:airmenuai_partner_app/core/presentation/widgets/premium_menu.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class TransferStockFormDialog extends StatelessWidget {
  const TransferStockFormDialog({super.key});

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
              children: [
                const Icon(
                  Icons.swap_horiz,
                  color: InventoryColors.primaryRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Transfer Stock',
                  style: AirMenuTextStyle.headingH4.withColor(
                    InventoryColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: InventoryColors.textQuaternary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            BlocBuilder<LocationFormCubit, LocationFormState>(
              builder: (context, state) {
                return PremiumDropdownField<String>(
                  label: 'From Location *',
                  displayValue: state.transferFrom ?? 'Select source location',
                  selectedValue: state.transferFrom,
                  width: 452,
                  items: [
                    PremiumPopupMenuItem(
                      value: 'Main Kitchen',
                      label: 'Main Kitchen',
                      icon: Icons.kitchen,
                    ),
                    PremiumPopupMenuItem(
                      value: 'Downtown Branch',
                      label: 'Downtown Branch',
                      icon: Icons.storefront,
                    ),
                    PremiumPopupMenuItem(
                      value: 'Central Warehouse',
                      label: 'Central Warehouse',
                      icon: Icons.warehouse,
                    ),
                    PremiumPopupMenuItem(
                      value: 'Cold Storage',
                      label: 'Cold Storage',
                      icon: Icons.ac_unit,
                    ),
                  ],
                  onSelected: (val) =>
                      context.read<LocationFormCubit>().setTransferFrom(val),
                );
              },
            ),
            const SizedBox(height: 16),

            BlocBuilder<LocationFormCubit, LocationFormState>(
              builder: (context, state) {
                return PremiumDropdownField<String>(
                  label: 'To Location *',
                  displayValue: state.transferTo ?? 'Select destination',
                  selectedValue: state.transferTo,
                  width: 452,
                  isEnabled: state.transferFrom != null,
                  items: [
                    if (state.transferFrom != 'Main Kitchen')
                      PremiumPopupMenuItem(
                        value: 'Main Kitchen',
                        label: 'Main Kitchen',
                        icon: Icons.kitchen,
                      ),
                    if (state.transferFrom != 'Downtown Branch')
                      PremiumPopupMenuItem(
                        value: 'Downtown Branch',
                        label: 'Downtown Branch',
                        icon: Icons.storefront,
                      ),
                    if (state.transferFrom != 'Central Warehouse')
                      PremiumPopupMenuItem(
                        value: 'Central Warehouse',
                        label: 'Central Warehouse',
                        icon: Icons.warehouse,
                      ),
                    if (state.transferFrom != 'Cold Storage')
                      PremiumPopupMenuItem(
                        value: 'Cold Storage',
                        label: 'Cold Storage',
                        icon: Icons.ac_unit,
                      ),
                  ],
                  onSelected: (val) =>
                      context.read<LocationFormCubit>().setTransferTo(val),
                );
              },
            ),
            const SizedBox(height: 16),

            // Item Selection (Simplified for mock)
            _DropdownFieldMock(
              label: 'Item *',
              value: 'Select source first',
              isEnabled: false,
            ),
            const SizedBox(height: 16),

            _TextField(label: 'Quantity *', hint: 'Enter quantity'),
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
                    foregroundColor: InventoryColors.textSecondaryStrong,
                  ),
                  child: Text(
                    'Cancel',
                    style: AirMenuTextStyle.normal.bold600(),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<LocationFormCubit, LocationFormState>(
                  builder: (context, state) {
                    final canSubmit =
                        state.transferFrom != null && state.transferTo != null;
                    return ElevatedButton.icon(
                      onPressed: (canSubmit && !state.isSubmitting)
                          ? () async {
                              await context
                                  .read<LocationFormCubit>()
                                  .submitTransfer();
                              if (context.mounted) Navigator.pop(context);
                            }
                          : null,
                      icon: state.isSubmitting
                          ? const SizedBox.shrink()
                          : const Icon(Icons.swap_horiz, size: 18),
                      label: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Transfer Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InventoryColors.primaryRed,
                        foregroundColor: Colors.white,
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

class _TextField extends StatefulWidget {
  final String label;
  final String hint;

  const _TextField({required this.label, required this.hint});

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AirMenuTextStyle.small.bold600().withColor(
            InventoryColors.textSecondaryStrong,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isFocused
                ? InventoryColors.bgRedTint
                : InventoryColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? InventoryColors.primaryRed
                  : InventoryColors.borderLight,
              width: 1, // Focus Border Logic from User Request
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            decoration: InputDecoration.collapsed(
              hintText: widget.hint,
              hintStyle: AirMenuTextStyle.normal.medium500().withColor(
                InventoryColors.textQuaternary,
              ),
            ),
            style: AirMenuTextStyle.normal.medium500(),
          ),
        ),
      ],
    );
  }
}

class _DropdownFieldMock extends StatelessWidget {
  final String label;
  final String value;
  final bool isEnabled;

  const _DropdownFieldMock({
    required this.label,
    required this.value,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.bold600().withColor(
            InventoryColors.textSecondaryStrong,
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: isEnabled ? 1 : 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: InventoryColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: InventoryColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AirMenuTextStyle.normal.medium500().withColor(
                    InventoryColors.textQuaternary,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: InventoryColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
