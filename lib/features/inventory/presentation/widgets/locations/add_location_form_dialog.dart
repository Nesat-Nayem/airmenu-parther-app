import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/location_form_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/locations_extended_cubit.dart';
import 'package:airmenuai_partner_app/core/presentation/widgets/premium_menu.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';

class AddLocationFormDialog extends StatelessWidget {
  final LocationModel? existing;

  const AddLocationFormDialog({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationFormCubit(),
      child: _DialogContent(existing: existing),
    );
  }
}

class _DialogContent extends StatefulWidget {
  final LocationModel? existing;
  const _DialogContent({this.existing});

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _managerCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.existing?.address ?? '');
    _managerCtrl = TextEditingController(text: widget.existing?.manager ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _managerCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

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
                  widget.existing == null ? 'Add New Location' : 'Edit Location',
                  style: AirMenuTextStyle.headingH4.withColor(
                    const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _LabeledTextField(label: 'Location Name *', hint: 'e.g., Downtown Branch', controller: _nameCtrl),
            const SizedBox(height: 16),

            BlocBuilder<LocationFormCubit, LocationFormState>(
              builder: (context, state) {
                return PremiumDropdownField<String>(
                  label: 'Type *',
                  displayValue: state.addLocationType,
                  selectedValue: state.addLocationType,
                  width: 452,
                  items: [
                    PremiumPopupMenuItem(value: 'Branch / Outlet', label: 'Branch / Outlet'),
                    PremiumPopupMenuItem(value: 'Warehouse', label: 'Warehouse'),
                    PremiumPopupMenuItem(value: 'Kitchen', label: 'Kitchen'),
                    PremiumPopupMenuItem(value: 'Storage Unit', label: 'Storage Unit'),
                  ],
                  onSelected: (val) => context.read<LocationFormCubit>().setAddLocationType(val),
                );
              },
            ),
            const SizedBox(height: 16),

            _LabeledTextField(label: 'Address *', hint: 'Full address', controller: _addressCtrl),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _LabeledTextField(label: 'Manager', hint: 'Manager name', controller: _managerCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _LabeledTextField(label: 'Phone', hint: '+91 XXXXX XXXXX', controller: _phoneCtrl)),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    foregroundColor: const Color(0xFF374151),
                  ),
                  child: Text('Cancel', style: AirMenuTextStyle.normal.bold600()),
                ),
                const SizedBox(width: 12),
                BlocBuilder<LocationFormCubit, LocationFormState>(
                  builder: (context, fState) {
                    return ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              final params = {
                                'name': _nameCtrl.text.trim(),
                                'type': fState.addLocationType,
                                'address': _addressCtrl.text.trim(),
                                'manager': _managerCtrl.text.trim(),
                                'phone': _phoneCtrl.text.trim(),
                              };
                              final locCubit = context.read<LocationsExtCubit>();
                              if (widget.existing == null) {
                                await locCubit.addLocation(params);
                              } else {
                                await locCubit.updateLocation(widget.existing!.id, params);
                              }
                              if (mounted) Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InventoryColors.primaryRed,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: InventoryColors.primaryRed.withOpacity(0.4),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              widget.existing == null ? 'Add Location' : 'Save Changes',
                              style: AirMenuTextStyle.normal.bold600().withColor(Colors.white),
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

class _LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;

  const _LabeledTextField({required this.label, required this.hint, this.controller});

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
            controller: controller,
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
