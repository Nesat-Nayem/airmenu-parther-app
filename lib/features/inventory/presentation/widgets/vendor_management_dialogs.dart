import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/bloc/vendor_cubit.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/constants/inventory_colors.dart';
import 'package:airmenuai_partner_app/features/inventory/presentation/widgets/inventory_shared_widgets.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';

typedef Vendor = VendorModel;

class VendorManagementDialog extends StatelessWidget {
  const VendorManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorCubit(locator<InventoryRepository>())..loadVendors(),
      child: const _VendorDialogContent(),
    );
  }
}

class _VendorDialogContent extends StatefulWidget {
  const _VendorDialogContent();

  @override
  State<_VendorDialogContent> createState() => _VendorDialogContentState();
}

class _VendorDialogContentState extends State<_VendorDialogContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, vendorState) {
        final filteredVendors = vendorState.vendors
            .where(
              (v) =>
                  v.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  v.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? screenWidth * 0.95 : 1000,
        height: isMobile ? MediaQuery.of(context).size.height * 0.9 : 700,
        decoration: BoxDecoration(
          color: InventoryColors.bgLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20), // Reduced from 24
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: InventoryColors.borderLight),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vendor Management',
                    style: AirMenuTextStyle.headingH3.bold700().withColor(
                      InventoryColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: InventoryColors.textQuaternary,
                    ),
                  ),
                ],
              ),
            ),

            // Toolbar
            Padding(
              padding: const EdgeInsets.all(20),
              child: isMobile
                  ? Column(
                      children: [
                        // Search Bar (Mobile)
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: InventoryColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 16,
                                color: InventoryColors.textQuaternary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  style: AirMenuTextStyle.small
                                      .medium500()
                                      .withColor(InventoryColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Search vendors...',
                                    hintStyle: AirMenuTextStyle.small
                                        .medium500()
                                        .withColor(
                                          InventoryColors.textQuaternary,
                                        ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : Row(
                      children: [
                        // Minimal Search Bar
                        Container(
                          width: 240,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: InventoryColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 16,
                                color: InventoryColors.textQuaternary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setState(() => _searchQuery = value),
                                  style: AirMenuTextStyle.small
                                      .medium500()
                                      .withColor(InventoryColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: AirMenuTextStyle.small
                                        .medium500()
                                        .withColor(
                                          InventoryColors.textQuaternary,
                                        ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '⌘K',
                                  style: AirMenuTextStyle.tiny
                                      .bold600()
                                      .withColor(const Color(0xFF9CA3AF)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        const Spacer(),

                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: context.read<VendorCubit>(),
                                child: AddEditVendorDialog(
                                  onSave: (v) => context.read<VendorCubit>().addVendor(v.toJson()),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Vendor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InventoryColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Vendor Grid
            Expanded(
              child: vendorState.status == VendorStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : vendorState.status == VendorStatus.error
                      ? Center(child: Text(vendorState.errorMessage))
                      : filteredVendors.isEmpty
                          ? const Center(child: Text('No vendors found'))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: filteredVendors
                                    .map(
                                      (vendor) => VendorCard(
                                        vendor: vendor,
                                        onEdit: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<VendorCubit>(),
                                              child: AddEditVendorDialog(
                                                vendor: vendor,
                                                onSave: (v) => context.read<VendorCubit>().updateVendor(v.id, v.toJson()),
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => RemoveVendorDialog(
                                              vendorName: vendor.companyName,
                                              onConfirm: () => context.read<VendorCubit>().removeVendor(vendor.id),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
      },
    );
  }
}

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: InventoryColors.bgRedTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store_mall_directory_outlined,
                  color: InventoryColors.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.companyName,
                      style: AirMenuTextStyle.normal.bold700().withColor(
                        InventoryColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      vendor.contactPerson,
                      style: AirMenuTextStyle.small.withColor(
                        InventoryColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: InventoryColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: InventoryColors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Info
          _buildInfoRow(Icons.phone_outlined, vendor.phone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email_outlined, vendor.email),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, vendor.address),
          const SizedBox(height: 16),

          // Supplies
          Text(
            'Supplies:',
            style: AirMenuTextStyle.small.medium500().withColor(
              InventoryColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...vendor.supplies.take(3).map((item) => _buildChip(item)),
              if (vendor.supplies.length > 3)
                _buildChip('+${vendor.supplies.length - 3} more', isMore: true),
            ],
          ),
          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              _buildTag(vendor.paymentTerms),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GST: ${vendor.gstNumber}',
                  style: AirMenuTextStyle.tiny.withColor(
                    InventoryColors.textQuaternary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'WhatsApp',
                  Icons.message_outlined,
                  Colors.green,
                ),
              ), // Using message icon as closest generic match or valid whatsapp icon
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Email',
                  Icons.email_outlined,
                  Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: InventoryColors.textQuaternary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AirMenuTextStyle.small.withColor(
              InventoryColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, {bool isMore = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMore ? InventoryColors.borderLight : InventoryColors.bgRedTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.tiny.medium500().withColor(
          isMore
              ? InventoryColors.textTertiary
              : InventoryColors.primaryDarkRed,
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: InventoryColors.borderLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AirMenuTextStyle.tiny.bold600().withColor(
          InventoryColors.textSecondaryStrong,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: InventoryColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color), // Simplified color usage
          const SizedBox(width: 6),
          Text(label, style: AirMenuTextStyle.small.bold600().withColor(color)),
        ],
      ),
    );
  }
}

class AddEditVendorDialog extends StatefulWidget {
  final Vendor? vendor;
  final Function(Vendor) onSave;

  const AddEditVendorDialog({super.key, this.vendor, required this.onSave});

  @override
  State<AddEditVendorDialog> createState() => _AddEditVendorDialogState();
}

class _AddEditVendorDialogState extends State<AddEditVendorDialog> {
  late TextEditingController _companyController;
  late TextEditingController _personController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _gstController;
  late TextEditingController _termsController;
  final TextEditingController _suppliesInputController =
      TextEditingController();

  List<String> _supplies = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(
      text: widget.vendor?.companyName,
    );
    _personController = TextEditingController(
      text: widget.vendor?.contactPerson,
    );
    _phoneController = TextEditingController(text: widget.vendor?.phone);
    _whatsappController = TextEditingController(text: widget.vendor?.whatsapp);
    _emailController = TextEditingController(text: widget.vendor?.email);
    _addressController = TextEditingController(text: widget.vendor?.address);
    _gstController = TextEditingController(text: widget.vendor?.gstNumber);
    _termsController = TextEditingController(text: widget.vendor?.paymentTerms);
    if (widget.vendor != null) {
      _supplies = List.from(widget.vendor!.supplies);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final vendor = Vendor(
        id:
            widget.vendor?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _companyController.text,
        contactPerson: _personController.text,
        phone: _phoneController.text,
        whatsapp: _whatsappController.text,
        email: _emailController.text,
        address: _addressController.text,
        gstNumber: _gstController.text,
        paymentTerms: _termsController.text,
        supplies: _supplies,
      );
      widget.onSave(vendor);
      Navigator.of(context).pop();
    }
  }

  void _addSupply() {
    if (_suppliesInputController.text.isNotEmpty) {
      setState(() {
        _supplies.add(_suppliesInputController.text);
        _suppliesInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 600,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20), // Reduced from 24
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.vendor == null ? 'Add Vendor' : 'Edit Vendor',
                    style: AirMenuTextStyle.headingH4.bold700().withColor(
                      const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20), // Reduced from 24
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Company Name', isRequired: true),
                      const SizedBox(height: 8),
                      _buildTextField(_companyController, 'Farm Fresh Meats'),
                      const SizedBox(height: 12),

                      _buildResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Contact Person', isRequired: true),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _personController,
                                'Suresh Patel',
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Phone', isRequired: true),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _phoneController,
                                '98765 43210',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (val.length != 10) {
                                    return 'Enter a valid 10-digit phone number';
                                  }
                                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val)) {
                                    return 'Enter a valid Indian phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('WhatsApp Number'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _whatsappController,
                                '98765 43210',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return null;
                                  }
                                  if (val.length != 10) {
                                    return 'Enter a valid 10-digit number';
                                  }
                                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(val)) {
                                    return 'Enter a valid Indian phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _emailController,
                                'supply@farmfresh.in',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Address'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _addressController,
                        '123 Meat Market...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      _buildResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('GST Number'),
                              const SizedBox(height: 8),
                              _buildTextField(_gstController, '27AABCD...'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Payment Terms'),
                              const SizedBox(height: 8),
                              _buildTextField(_termsController, 'Net 7'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Supplied Items'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _suppliesInputController,
                              'Add item (e.g., Paneer)',
                              onSubmitted: (_) => _addSupply(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _addSupply,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _supplies
                            .map(
                              (supply) => Chip(
                                label: Text(supply),
                                backgroundColor: const Color(0xFFFEF2F2),
                                labelStyle: AirMenuTextStyle.small.withColor(
                                  const Color(0xFF991B1B),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF991B1B),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _supplies.remove(supply);
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Notes'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        TextEditingController(text: widget.vendor?.notes),
                        'Additional notes...',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InventorySecondaryButton(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  InventoryPrimaryButton(label: 'Save Changes', onTap: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AirMenuTextStyle.small.bold600().withColor(
            const Color(0xFF374151),
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: AirMenuTextStyle.small.bold600().withColor(Colors.red),
          ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    Function(String)? onSubmitted,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        onFieldSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: validator ??
            (val) {
              if (controller == _companyController ||
                  controller == _personController ||
                  controller == _phoneController) {
                if (val == null || val.isEmpty) return 'Required';
              }
              return null;
            },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AirMenuTextStyle.normal.withColor(const Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: maxLines > 1
              ? const EdgeInsets.symmetric(vertical: 12)
              : null,
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({
    required bool isMobile,
    required List<Widget> children,
  }) {
    if (isMobile) {
      return Column(
        children: children
            .expand((child) => [child, const SizedBox(height: 12)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .expand((child) => [child, const SizedBox(width: 12)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

class RemoveVendorDialog extends StatelessWidget {
  final String vendorName;
  final VoidCallback onConfirm;

  const RemoveVendorDialog({
    super.key,
    required this.vendorName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isMobile ? screenWidth * 0.9 : 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remove Vendor',
                  style: AirMenuTextStyle.headingH4.bold700().withColor(
                    const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to remove this vendor?\nThis action cannot be undone.',
              style: AirMenuTextStyle.normal.withColor(const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24), // Reduced from 32
            Row(
              children: [
                Expanded(
                  child: InventorySecondaryButton(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InventoryPrimaryButton(
                    label: 'Remove',
                    onTap: () {
                      onConfirm();
                      Navigator.pop(context);
                    },
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
