import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import '../bloc/tables_bloc.dart';
import 'qr_code_dialog.dart';
import 'table_detail_dialog.dart';

/// Shared Tokens — Lovable Tables & QR cards.
abstract final class TableCardLayout {
  static const double radius = 16;
  static const Color canvas = Color(0xFFFCFBF9);
  static const Color foreground = Color(0xFF2A3038);
  static const Color muted = Color(0xFF7A8494);
  static const Color idleBorder = Color(0xFFECE8E6);
  static const Color accent = Color(0xFFD4353A);

  static Color statusDot(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return const Color(0xFF22C55E);
      case TableStatus.occupied:
        return accent;
      case TableStatus.reserved:
        return const Color(0xFFF59E0B);
      case TableStatus.cleaning:
        return const Color(0xFF6B7280);
    }
  }

  static Color statusTint(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return const Color(0xFF22C55E).withValues(alpha: 0.08);
      case TableStatus.occupied:
        return accent.withValues(alpha: 0.08);
      case TableStatus.reserved:
        return const Color(0xFFF59E0B).withValues(alpha: 0.10);
      case TableStatus.cleaning:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color statusBorder(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return const Color(0xFF22C55E).withValues(alpha: 0.28);
      case TableStatus.occupied:
        return accent.withValues(alpha: 0.28);
      case TableStatus.reserved:
        return const Color(0xFFF59E0B).withValues(alpha: 0.30);
      case TableStatus.cleaning:
        return idleBorder;
    }
  }

  static String statusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }
}

/// Lovable glass table card — fixed border hover (MouseTracker-safe).
class TableCard extends StatefulWidget {
  final TableModel table;
  final int animationIndex;

  const TableCard({
    super.key,
    required this.table,
    this.animationIndex = 0,
  });

  @override
  State<TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<TableCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;

  TableModel get table => widget.table;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);

    final delay = Duration(milliseconds: 30 * widget.animationIndex.clamp(0, 20));
    Future.delayed(delay, () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = TableCardLayout.statusDot(table.status);

    return FadeTransition(
      opacity: _fade,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => TableDetailDialog(table: table),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(TableCardLayout.radius),
              border: Border.all(
                color: _hovered
                    ? statusColor.withValues(alpha: 0.45)
                    : TableCardLayout.statusBorder(table.status),
                width: 1.5,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(statusColor),
                const SizedBox(height: 12),
                _buildMeta(),
                const SizedBox(height: 10),
                Expanded(child: _buildStatusBody()),
                Divider(
                  height: 1,
                  color: TableCardLayout.idleBorder.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 10),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'T-${table.tableNumber}',
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TableCardLayout.foreground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _IconBtn(
          icon: Icons.qr_code_2_rounded,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => QrCodeDialog(table: table),
            );
          },
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.more_horiz_rounded,
            size: 20,
            color: Colors.grey.shade400,
          ),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Icon(Icons.people_outline_rounded, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          '${table.capacity} seats',
          style: GoogleFonts.sora(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: TableCardLayout.muted,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              table.zone,
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: TableCardLayout.muted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBody() {
    if (table.status == TableStatus.occupied) {
      final shortId = table.id.length > 4
          ? table.id.substring(table.id.length - 4).toUpperCase()
          : table.id;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                '#$shortId',
                style: GoogleFonts.sora(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: TableCardLayout.foreground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Active',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: TableCardLayout.muted,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (table.status == TableStatus.cleaning) {
      return Text(
        'Being prepared...',
        style: GoogleFonts.sora(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: TableCardLayout.muted,
        ),
      );
    }

    if (table.status == TableStatus.reserved) {
      return Text(
        'Reserved',
        style: GoogleFonts.sora(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFD97706),
        ),
      );
    }

    return Text(
      'Ready for guests',
      style: GoogleFonts.sora(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: TableCardLayout.muted,
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFF8F6F4),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => QrCodeDialog(table: table),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 15, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'QR Code',
                      style: GoogleFonts.sora(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.visibility_outlined,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => TableDetailDialog(table: table),
            );
          },
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final tableNumberController = TextEditingController(text: table.tableNumber);
    final capacityController =
        TextEditingController(text: table.capacity.toString());
    final blocZoneNames = context.read<TablesBloc>().state.zoneNames;
    final zoneItems = blocZoneNames.isNotEmpty
        ? (blocZoneNames.contains(table.zone)
            ? blocZoneNames
            : [table.zone, ...blocZoneNames])
        : [table.zone];
    String selectedZone = table.zone;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Table',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TableCardLayout.foreground,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(Icons.close, size: 22, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table Number',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tableNumberController,
                          decoration: InputDecoration(
                            hintText: 'e.g., T-13',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Capacity',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Number of seats',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (int.tryParse(v) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Zone',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedZone,
                              isExpanded: true,
                              items: zoneItems.map((z) {
                                return DropdownMenuItem(
                                  value: z,
                                  child: Text(
                                    z,
                                    style: GoogleFonts.sora(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => selectedZone = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final updatedTable = TableModel(
                              id: table.id,
                              tableNumber: tableNumberController.text.trim(),
                              capacity: int.parse(capacityController.text.trim()),
                              zone: selectedZone,
                              status: table.status,
                              qrUrl: table.qrUrl,
                              hotelId: table.hotelId,
                            );
                            context.read<TablesBloc>().add(
                                  UpdateTable(updatedTable),
                                );
                            Navigator.pop(dialogContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TableCardLayout.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Table',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete table T-${table.tableNumber}? This action cannot be undone.',
          style: GoogleFonts.sora(fontSize: 14, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TablesBloc>().add(DeleteTable(table.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TableCardLayout.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

/// Skeleton matching [TableCard] height/structure.
class TableCardSkeleton extends StatelessWidget {
  const TableCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TableCardLayout.radius),
        border: Border.all(color: TableCardLayout.idleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bone(10, 10, 999),
              const SizedBox(width: 8),
              _bone(64, 16, 4),
              const Spacer(),
              _bone(28, 28, 8),
            ],
          ),
          const SizedBox(height: 14),
          _bone(110, 12, 4),
          const SizedBox(height: 12),
          _bone(80, 12, 4),
          const Spacer(),
          Container(height: 1, color: TableCardLayout.idleBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _bone(double.infinity, 34, 10)),
              const SizedBox(width: 8),
              _bone(34, 34, 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bone(double w, double h, double r) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFECE8E6),
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
