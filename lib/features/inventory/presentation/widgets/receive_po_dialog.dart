import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:airmenuai_partner_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ReceivePurchaseOrderDialog extends StatefulWidget {
  final PurchaseOrder order;
  final VoidCallback? onReceived;

  const ReceivePurchaseOrderDialog({
    super.key,
    required this.order,
    this.onReceived,
  });

  static Future<bool?> show(
    BuildContext context, {
    required PurchaseOrder order,
    VoidCallback? onReceived,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReceivePurchaseOrderDialog(order: order, onReceived: onReceived),
    );
  }

  @override
  State<ReceivePurchaseOrderDialog> createState() => _ReceivePurchaseOrderDialogState();
}

class _ReceiveLine {
  final PurchaseOrderItem item;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final List<_ExpiryBatchEntry> expiryBatches;

  _ReceiveLine(this.item)
      : qtyController = TextEditingController(
          text: item.remainingQuantity > 0 ? item.remainingQuantity.toStringAsFixed(0) : '0',
        ),
        priceController = TextEditingController(
          text: _fmt(item.receivedUnitPrice ?? item.unitPrice),
        ),
        expiryBatches = [
          _ExpiryBatchEntry(
            qtyController: TextEditingController(
              text: item.remainingQuantity > 0 ? item.remainingQuantity.toStringAsFixed(0) : '0',
            ),
            expiryDate: DateTime.now().add(const Duration(days: 30)),
          ),
        ];

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    for (final b in expiryBatches) {
      b.qtyController.dispose();
    }
  }
}

class _ExpiryBatchEntry {
  final TextEditingController qtyController;
  DateTime expiryDate;

  _ExpiryBatchEntry({required this.qtyController, required this.expiryDate});

  void dispose() => qtyController.dispose();
}

class _ReceivePurchaseOrderDialogState extends State<ReceivePurchaseOrderDialog> {
  late final List<_ReceiveLine> _lines;
  final TextEditingController _notesController = TextEditingController();
  String? _slipUrl;
  String? _slipName;
  bool _isSubmitting = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _lines = widget.order.items
        .where((i) => i.remainingQuantity > 0)
        .map(_ReceiveLine.new)
        .toList();
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickSlip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);
    final file = result.files.first;
    final repo = locator<InventoryRepository>();
    final upload = await repo.uploadFile(
      filePath: file.path,
      bytes: file.bytes,
      fileName: file.name,
    );
    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (upload is DataSuccess<String>) {
        _slipUrl = upload.data;
        _slipName = file.name;
      }
    });
    if (upload is! DataSuccess<String>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(upload.error?.message ?? 'Failed to upload slip')),
      );
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final items = <Map<String, dynamic>>[];

    for (final line in _lines) {
      final receivedQty = double.tryParse(line.qtyController.text.trim()) ?? 0;
      if (receivedQty <= 0) continue;
      if (receivedQty > line.item.remainingQuantity + 0.0001) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Received qty exceeds remaining for ${line.item.materialName}')),
        );
        return;
      }

      final batchTotal = line.expiryBatches.fold<double>(
        0,
        (sum, b) => sum + (double.tryParse(b.qtyController.text.trim()) ?? 0),
      );
      if ((batchTotal - receivedQty).abs() > 0.0001) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expiry batches must total ${receivedQty.toStringAsFixed(0)} for ${line.item.materialName}')),
        );
        return;
      }

      items.add({
        'materialId': line.item.materialId,
        'receivedQuantity': receivedQty,
        'receivedUnitPrice': double.tryParse(line.priceController.text.trim()) ?? line.item.unitPrice,
        'expiryBatches': line.expiryBatches
            .where((b) => (double.tryParse(b.qtyController.text.trim()) ?? 0) > 0)
            .map((b) => {
                  'quantity': double.tryParse(b.qtyController.text.trim()) ?? 0,
                  'expiryDate': b.expiryDate.toIso8601String(),
                })
            .toList(),
      });
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one received quantity')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final res = await locator<InventoryRepository>().receivePurchaseOrder(
      widget.order.id,
      {
        if (_slipUrl != null) 'receiveSlipUrl': _slipUrl,
        if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
        'items': items,
      },
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res is DataSuccess<PurchaseOrder>) {
      widget.onReceived?.call();
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Purchase order received — stock updated'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error?.message ?? 'Failed to receive purchase order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 640,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receive Purchase Order',
                            style: AirMenuTextStyle.headingH4.bold700()),
                        Text(
                          widget.order.vendorName.isNotEmpty ? widget.order.vendorName : 'Vendor',
                          style: AirMenuTextStyle.small.medium500().withColor(const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _lines.isEmpty
                  ? const Center(child: Text('All items on this order are already received.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _lines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _buildLineCard(_lines[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickSlip,
                    icon: _isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file, size: 18),
                    label: Text(_slipName ?? 'Upload receive slip (optional)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Receive notes (optional)',
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting || _lines.isEmpty ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Confirm Receive'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineCard(_ReceiveLine line) {
    final item = line.item;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.materialName, style: AirMenuTextStyle.normal.bold600()),
          Text(
            'Ordered ${item.quantity.toStringAsFixed(0)} ${item.unit} · Received ${item.receivedQuantity.toStringAsFixed(0)} · Remaining ${item.remainingQuantity.toStringAsFixed(0)}',
            style: AirMenuTextStyle.caption.medium500().withColor(const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('Receive Qty', line.qtyController, suffix: item.unit)),
              const SizedBox(width: 10),
              Expanded(child: _field('Unit Price (₹)', line.priceController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expiry Batches', style: AirMenuTextStyle.small.bold600()),
              TextButton.icon(
                onPressed: () => setState(() {
                  line.expiryBatches.add(_ExpiryBatchEntry(
                    qtyController: TextEditingController(text: '0'),
                    expiryDate: DateTime.now().add(const Duration(days: 30)),
                  ));
                }),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add batch'),
              ),
            ],
          ),
          ...line.expiryBatches.asMap().entries.map((e) {
            final batch = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: _field('Batch qty', batch.qtyController, suffix: item.unit)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: batch.expiryDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) setState(() => batch.expiryDate = picked);
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(batch.expiryDate)),
                    ),
                  ),
                  if (line.expiryBatches.length > 1)
                    IconButton(
                      onPressed: () => setState(() {
                        batch.dispose();
                        line.expiryBatches.removeAt(e.key);
                      }),
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFFDC2626)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AirMenuTextStyle.caption.medium500().withColor(const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            suffixText: suffix,
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
