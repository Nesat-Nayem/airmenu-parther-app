import 'package:airmenuai_partner_app/core/network/data_state.dart';
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
                            final cubit = context.read<VendorCubit>();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: AddEditVendorDialog(
                                  onSave: (v) => cubit.addVendor(v.toJson()),
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
                                          final cubit = context.read<VendorCubit>();
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => BlocProvider.value(
                                              value: cubit,
                                              child: AddEditVendorDialog(
                                                vendor: vendor,
                                                onSave: (v) => cubit.updateVendor(v.id, v.toJson()),
                                              ),
                                            ),
                                          );
                                        },
                                        onDelete: () {
                                          final cubit = context.read<VendorCubit>();
                                          final rootMessenger = ScaffoldMessenger.of(context);
                                          showDialog(
                                            context: context,
                                            builder: (_) => RemoveVendorDialog(
                                              vendorName: vendor.companyName,
                                              onConfirm: () async {
                                                final err = await cubit.removeVendor(vendor.id);
                                                if (err == null) {
                                                  rootMessenger.showSnackBar(
                                                    const SnackBar(
                                                      backgroundColor: Color(0xFF16A34A),
                                                      content: Text('Vendor removed'),
                                                    ),
                                                  );
                                                } else {
                                                  rootMessenger.showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: const Color(0xFFDC2626),
                                                      content: Text(err),
                                                    ),
                                                  );
                                                }
                                              },
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: const Color(0xFFDC2626), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
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
                        style: AirMenuTextStyle.normal
                            .bold700()
                            .withColor(InventoryColors.textPrimary)
                            .copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: InventoryColors.textQuaternary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor.contactPerson,
                              style: AirMenuTextStyle.small.withColor(
                                InventoryColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: InventoryColors.textTertiary,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: InventoryColors.primaryRed,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // Contact Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildInfoRow(Icons.phone_outlined, vendor.phone, muted: false),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.email_outlined, vendor.email),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on_outlined, vendor.address),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // GST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 12,
                  color: InventoryColors.textQuaternary,
                ),
                const SizedBox(width: 6),
                Text(
                  'GST: ${vendor.gstNumber}',
                  style: AirMenuTextStyle.tiny.withColor(
                    InventoryColors.textQuaternary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Supplies
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supplies',
                  style: AirMenuTextStyle.tiny.bold600().withColor(
                    InventoryColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...vendor.supplies.take(3).map((item) => _buildChip(item)),
                    if (vendor.supplies.length > 3)
                      _buildChip(
                        '+${vendor.supplies.length - 3} more',
                        isMore: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                Expanded(child: _buildActionButton('WhatsApp', Icons.message_outlined, isWhatsApp: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildActionButton('Email', Icons.email_outlined, isEmail: true)),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool muted = true}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: muted
              ? InventoryColors.textQuaternary
              : InventoryColors.textTertiary,
        ),
        const SizedBox(width: 7),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMore ? const Color(0xFFF3F4F6) : InventoryColors.bgRedTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMore
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFDC2626).withOpacity(0.15),
          width: 0.5,
        ),
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

  Widget _buildActionButton(
    String label,
    IconData icon, {
    bool isWhatsApp = false,
    bool isEmail = false,
  }) {
    final Color bgColor = isWhatsApp
        ? const Color(0xFFDCFCE7)
        : isEmail
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF3F4F6);
    final Color fgColor = isWhatsApp
        ? const Color(0xFF16A34A)
        : isEmail
            ? const Color(0xFF2563EB)
            : InventoryColors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AirMenuTextStyle.small.bold600().withColor(fgColor),
          ),
        ],
      ),
    );
  }
}

class AddEditVendorDialog extends StatefulWidget {
  final Vendor? vendor;
  final Future<String?> Function(Vendor) onSave;

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

  // Each supplied item pairs a material with the price this vendor charges.
  final List<_SupplyEntry> _suppliedItems = [];
  List<InventoryItem> _materials = [];
  bool _loadingMaterials = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

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
    if (widget.vendor != null) {
      for (final s in widget.vendor!.suppliedItems) {
        _suppliedItems.add(_SupplyEntry(
          materialId: s.materialId.isNotEmpty ? s.materialId : null,
          materialName: s.materialName,
          priceController: TextEditingController(text: _fmtPrice(s.price)),
          minOrderController: TextEditingController(text: _fmtPrice(s.minOrderQty)),
          deliveryController: TextEditingController(text: '${s.deliveryDays}'),
        ));
      }
    }
    _fetchMaterials();
  }

  static String _fmtPrice(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _companyController.dispose();
    _personController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    for (final e in _suppliedItems) {
      e.priceController.dispose();
      e.minOrderController.dispose();
      e.deliveryController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _loadingMaterials = true);
    final res = await locator<InventoryRepository>().getMaterials();
    if (!mounted) return;
    setState(() {
      if (res is DataSuccess<List<InventoryItem>>) {
        _materials = res.data!;
        // Backfill materialId for legacy entries stored only by name.
        for (final e in _suppliedItems) {
          if (e.materialId == null && e.materialName.isNotEmpty) {
            final match = _materials.where((m) => m.name == e.materialName).firstOrNull;
            if (match != null) e.materialId = match.id;
          }
        }
      }
      _loadingMaterials = false;
    });
  }

  void _addSupplyEntry() {
    setState(() {
      _suppliedItems.add(_SupplyEntry(
        priceController: TextEditingController(),
        minOrderController: TextEditingController(text: '1'),
        deliveryController: TextEditingController(text: '1'),
      ));
    });
  }

  void _removeSupplyEntry(int index) {
    setState(() {
      _suppliedItems[index].priceController.dispose();
      _suppliedItems[index].minOrderController.dispose();
      _suppliedItems[index].deliveryController.dispose();
      _suppliedItems.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final entries = _suppliedItems.where((e) => e.materialId != null).toList();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          content: Text('Please add at least one supplied item'),
        ),
      );
      return;
    }
    final suppliedItems = entries.map((e) {
      final mat = _materials.where((m) => m.id == e.materialId).firstOrNull;
      return SuppliedItem(
        materialId: e.materialId!,
        materialName: mat?.name ?? e.materialName,
        price: double.tryParse(e.priceController.text.trim()) ?? 0,
        minOrderQty: double.tryParse(e.minOrderController.text.trim()) ?? 1,
        deliveryDays: int.tryParse(e.deliveryController.text.trim()) ?? 1,
      );
    }).toList();
    final vendor = Vendor(
      id: widget.vendor?.id ?? '',
      companyName: _companyController.text.trim(),
      contactPerson: _personController.text.trim(),
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      gstNumber: _gstController.text.trim(),
      paymentTerms: widget.vendor?.paymentTerms ?? '',
      suppliedItems: suppliedItems,
    );
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final err = await widget.onSave(vendor);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (err == null) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          content: Text(widget.vendor == null ? 'Vendor created' : 'Vendor updated'),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          content: Text(err),
        ),
      );
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
                              _buildLabel('WhatsApp Number', isRequired: true),
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
                                    return 'WhatsApp number is required';
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
                              _buildLabel('Email', isRequired: true),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _emailController,
                                'supply@farmfresh.in',
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Address', isRequired: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _addressController,
                        '123 Meat Market...',
                        maxLines: 3,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('GST Number', isRequired: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _gstController,
                        '27AABCD...',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'GST number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Supplied Items & Pricing'),
                          if (!_loadingMaterials && _materials.isNotEmpty)
                            TextButton.icon(
                              onPressed: _addSupplyEntry,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Item'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                textStyle: AirMenuTextStyle.small.bold600(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_loadingMaterials)
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        )
                      else if (_materials.isEmpty)
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            'No materials found. Add materials first.',
                            style: AirMenuTextStyle.normal.withColor(const Color(0xFF9CA3AF)),
                          ),
                        )
                      else if (_suppliedItems.isEmpty)
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            'Tap "Add Item" to add a supplied material and its price.',
                            style: AirMenuTextStyle.normal.withColor(const Color(0xFF9CA3AF)),
                          ),
                        )
                      else
                        Column(
                          children: _suppliedItems
                              .asMap()
                              .entries
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildSupplyRow(e.key, e.value),
                                  ))
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
                    onTap: _isSaving ? () {} : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  InventoryPrimaryButton(
                    label: _isSaving
                        ? (widget.vendor == null ? 'Creating...' : 'Saving...')
                        : 'Save Changes',
                    isLoading: _isSaving,
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyRow(int index, _SupplyEntry entry) {
    final selectedIds = _suppliedItems
        .asMap()
        .entries
        .where((e) => e.key != index)
        .map((e) => e.value.materialId)
        .whereType<String>()
        .toSet();
    final value = _materials.any((m) => m.id == entry.materialId) ? entry.materialId : null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: value,
                    isExpanded: true,
                    hint: Text('Select material',
                        style: AirMenuTextStyle.small.withColor(const Color(0xFF9CA3AF))),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    items: _materials
                        .where((m) => m.id == entry.materialId || !selectedIds.contains(m.id))
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text('${m.name} (${m.unit})',
                                  overflow: TextOverflow.ellipsis,
                                  style: AirMenuTextStyle.small.medium500()),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      final m = _materials.where((m) => m.id == val).firstOrNull;
                      entry.materialId = val;
                      entry.materialName = m?.name ?? '';
                    }),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeSupplyEntry(index),
                icon: const Icon(Icons.close, size: 18, color: Color(0xFFDC2626)),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSupplyField(entry.priceController, 'Price (₹)', isNumber: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildSupplyField(entry.minOrderController, 'Min Order Qty', isNumber: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildSupplyField(entry.deliveryController, 'Delivery (days)', isNumber: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))] : null,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          hintStyle: AirMenuTextStyle.tiny.withColor(const Color(0xFF9CA3AF)),
        ),
        style: AirMenuTextStyle.small.medium500(),
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

// Mutable form-row model for a vendor's supplied item + price.
class _SupplyEntry {
  String? materialId;
  String materialName;
  final TextEditingController priceController;
  final TextEditingController minOrderController;
  final TextEditingController deliveryController;

  _SupplyEntry({
    this.materialId,
    this.materialName = '',
    required this.priceController,
    required this.minOrderController,
    required this.deliveryController,
  });
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
