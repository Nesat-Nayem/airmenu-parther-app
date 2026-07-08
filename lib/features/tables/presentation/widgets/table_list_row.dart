import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import '../widgets/qr_code_dialog.dart';
import '../widgets/table_detail_dialog.dart';
import 'table_card.dart';

/// Lovable list-row for Tables & QR.
class TableListRow extends StatefulWidget {
  final TableModel table;
  final int animationIndex;
  final bool isLast;

  const TableListRow({
    super.key,
    required this.table,
    this.animationIndex = 0,
    this.isLast = false,
  });

  @override
  State<TableListRow> createState() => _TableListRowState();
}

class _TableListRowState extends State<TableListRow>
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
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    final delay =
        Duration(milliseconds: 25 * widget.animationIndex.clamp(0, 24));
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
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFFF8F6F4)
                  : Colors.white,
              border: widget.isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: TableCardLayout.idleBorder.withValues(alpha: 0.9),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'T-${table.tableNumber}',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TableCardLayout.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    table.zone,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: TableCardLayout.muted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${table.capacity} seats',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: TableCardLayout.muted,
                    ),
                  ),
                ),
                Expanded(child: _StatusChip(status: table.status)),
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => QrCodeDialog(table: table),
                          );
                        },
                        icon: Icon(
                          Icons.qr_code_2_rounded,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => TableDetailDialog(table: table),
                          );
                        },
                        icon: Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
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
}

class _StatusChip extends StatelessWidget {
  final TableStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = TableCardLayout.statusDot(status);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          TableCardLayout.statusLabel(status),
          style: GoogleFonts.sora(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
