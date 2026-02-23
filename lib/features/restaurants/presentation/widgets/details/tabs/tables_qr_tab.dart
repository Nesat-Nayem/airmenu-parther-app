import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/features/tables/data/models/table_model.dart';
import 'package:airmenuai_partner_app/features/tables/data/repositories/table_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:shimmer/shimmer.dart';

import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    as download_helper;

class TablesQrTab extends StatefulWidget {
  final String hotelId;

  const TablesQrTab({super.key, required this.hotelId});

  @override
  State<TablesQrTab> createState() => _TablesQrTabState();
}

class _TablesQrTabState extends State<TablesQrTab> {
  late final TableRepository _repo;
  List<TableModel> _tables = [];
  List<TableModel> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';
  bool _isSaving = false;
  bool _isDownloadingAll = false;

  @override
  void initState() {
    super.initState();
    _repo = TableRepository(apiService: locator<ApiService>());
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final tables = await _repo.getTablesByHotelId(widget.hotelId);
      setState(() {
        _tables = tables;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilter() {
    if (_search.isEmpty) {
      _filtered = _tables;
    } else {
      final q = _search.toLowerCase();
      _filtered = _tables.where((t) =>
        t.tableNumber.toLowerCase().contains(q)
      ).toList();
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddEditDialog({TableModel? table}) async {
    final tableCtrl = TextEditingController(text: table?.tableNumber ?? '');
    final seatCtrl = TextEditingController(text: table != null ? '${table.capacity}' : '');
    final isEdit = table != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Table' : 'Add New Table',
          style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tableCtrl,
                decoration: InputDecoration(
                  labelText: 'Table Number *',
                  hintText: 'e.g. T1, Table 5',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.table_restaurant_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: seatCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Seat Capacity *',
                  hintText: 'e.g. 4',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.people_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          StatefulBuilder(
            builder: (ctx2, setDialogState) {
              return ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  final tableNum = tableCtrl.text.trim();
                  final seats = int.tryParse(seatCtrl.text.trim()) ?? 0;
                  if (tableNum.isEmpty) {
                    _showSnackBar('Table number is required', isError: true);
                    return;
                  }
                  if (seats < 1) {
                    _showSnackBar('Seat capacity must be at least 1', isError: true);
                    return;
                  }
                  setState(() => _isSaving = true);
                  setDialogState(() {});
                  try {
                    if (isEdit) {
                      await _repo.updateTable(
                        id: table.id,
                        hotelId: widget.hotelId,
                        tableNumber: tableNum,
                        seatNumber: seats,
                        capacity: seats,
                      );
                      _showSnackBar('Table updated successfully');
                    } else {
                      await _repo.addTableForHotel(
                        hotelId: widget.hotelId,
                        tableNumber: tableNum,
                        seatNumber: seats,
                        capacity: seats,
                      );
                      _showSnackBar('Table created successfully');
                    }
                    if (mounted) Navigator.pop(ctx, true);
                  } catch (e) {
                    _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC52031),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Update' : 'Create'),
              );
            },
          ),
        ],
      ),
    );

    if (result == true) _loadTables();
  }

  Future<void> _confirmDelete(TableModel table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Table ${table.tableNumber}?', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        content: const Text('This will permanently delete this table and its QR code. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repo.deleteTable(table.id);
        _showSnackBar('Table deleted successfully');
        _loadTables();
      } catch (e) {
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _downloadQr(TableModel table) {
    if (table.qrUrl.isEmpty) {
      _showSnackBar('No QR code image available', isError: true);
      return;
    }
    _showQrPreviewDialog(table);
  }

  void _triggerSingleDownload(TableModel table) {
    if (table.qrUrl.isEmpty) {
      _showSnackBar('No QR code image available', isError: true);
      return;
    }
    if (kIsWeb) {
      download_helper.downloadFileFromUrl(
        table.qrUrl,
        'table_${table.tableNumber}_qrcode.png',
      );
      _showSnackBar('Downloading QR code for Table ${table.tableNumber}');
    } else {
      _showSnackBar('Download is only supported on web', isError: true);
    }
  }

  Future<void> _downloadAllQr() async {
    if (!kIsWeb) {
      _showSnackBar('Download All is only supported on web', isError: true);
      return;
    }
    setState(() => _isDownloadingAll = true);
    try {
      final urls = await _repo.getDownloadAllUrls(widget.hotelId);
      if (urls.isEmpty) {
        _showSnackBar('No QR codes to download', isError: true);
        return;
      }
      for (final item in urls) {
        final url = item['qrCodeImage'] ?? '';
        final tableNum = item['tableNumber'] ?? '';
        if (url.isNotEmpty) {
          download_helper.downloadFileFromUrl(url, 'table_${tableNum}_qrcode.png');
        }
      }
      _showSnackBar('Downloading ${urls.length} QR codes');
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isDownloadingAll = false);
    }
  }

  void _showQrPreviewDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('QR Code - Table ${table.tableNumber}', style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 16)),
        content: SizedBox(
          width: 300,
          height: 320,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: table.qrUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              Text('Seats: ${table.capacity}', style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade600)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (kIsWeb)
            ElevatedButton.icon(
              onPressed: () {
                _triggerSingleDownload(table);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC52031),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tables & QR Codes', style: AirMenuTextStyle.headingH4.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        _isLoading ? 'Loading...' : '${_tables.length} tables configured',
                        style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_tables.isNotEmpty && kIsWeb) ...[
                        OutlinedButton.icon(
                          onPressed: _isLoading || _isDownloadingAll ? null : _downloadAllQr,
                          icon: _isDownloadingAll
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(_isDownloadingAll ? 'Downloading...' : 'Download All QR'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _showAddEditDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Table'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC52031),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search
              SizedBox(
                height: 44,
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by table number...',
                    hintStyle: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: AirMenuTextStyle.small,
                  onChanged: (v) {
                    setState(() { _search = v; _applyFilter(); });
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Content
              if (_isLoading) _buildSkeleton(),
              if (!_isLoading && _error != null) _buildError(),
              if (!_isLoading && _error == null && _filtered.isEmpty) _buildEmpty(),
              if (!_isLoading && _error == null && _filtered.isNotEmpty) _buildGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: List.generate(6, (_) => Container(
          width: 320,
          height: 140,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        )),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Failed to load tables', style: AirMenuTextStyle.normal),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadTables, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Icon(Icons.table_restaurant_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No tables found', style: AirMenuTextStyle.normal.copyWith(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Create your first table to generate a QR code', style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        final width = (constraints.maxWidth - (24 * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: _filtered.map((table) => SizedBox(width: width, child: _buildTableCard(table))).toList(),
        );
      },
    );
  }

  Widget _buildTableCard(TableModel table) {
    final statusLabel = _statusLabel(table.status);
    final statusColor = _statusColor(table.status);
    final statusBg = _statusBgColor(table.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR thumbnail
          GestureDetector(
            onTap: () => _downloadQr(table),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: table.qrUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: table.qrUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        width: 64, height: 64,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.qr_code_2, size: 32, color: Color(0xFF9CA3AF)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 64, height: 64,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.broken_image, size: 32, color: Color(0xFF9CA3AF)),
                      ),
                    )
                  : Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.qr_code_2, color: Color(0xFFF43F5E), size: 32),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table ${table.tableNumber}',
                      style: AirMenuTextStyle.normal.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(statusLabel, style: AirMenuTextStyle.tiny.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Seats: ${table.capacity}', style: AirMenuTextStyle.small.copyWith(color: const Color(0xFF6B7280))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _actionButton(Icons.visibility_outlined, 'View QR', () => _downloadQr(table)),
                    if (kIsWeb)
                      _actionButton(Icons.download_rounded, 'Download', () => _triggerSingleDownload(table)),
                    _actionButton(Icons.edit_outlined, 'Edit', () => _showAddEditDialog(table: table)),
                    _actionButton(Icons.delete_outline, 'Delete', () => _confirmDelete(table), isDestructive: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? const Color(0xFFDC2626) : const Color(0xFF6B7280);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  String _statusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.vacant: return 'Available';
      case TableStatus.occupied: return 'Occupied';
      case TableStatus.reserved: return 'Reserved';
      case TableStatus.cleaning: return 'Cleaning';
    }
  }

  Color _statusColor(TableStatus status) {
    switch (status) {
      case TableStatus.vacant: return const Color(0xFF15803D);
      case TableStatus.occupied: return const Color(0xFFD97706);
      case TableStatus.reserved: return const Color(0xFF2563EB);
      case TableStatus.cleaning: return const Color(0xFF4B5563);
    }
  }

  Color _statusBgColor(TableStatus status) {
    switch (status) {
      case TableStatus.vacant: return const Color(0xFFDCFCE7);
      case TableStatus.occupied: return const Color(0xFFFEF3C7);
      case TableStatus.reserved: return const Color(0xFFDBEAFE);
      case TableStatus.cleaning: return const Color(0xFFF3F4F6);
    }
  }
}
