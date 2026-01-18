import 'dart:async';

import 'package:airmenuai_partner_app/features/kitchen/config/kitchen_config.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kitchen task card optimized for KDS display showing multiple items per order
class KitchenOrderCard extends StatefulWidget {
  final List<KitchenTaskModel> tasks;
  final VoidCallback? onStartPrep;
  final VoidCallback? onMarkReady;
  final VoidCallback? onTap;
  final bool isLoading;

  const KitchenOrderCard({
    super.key,
    required this.tasks,
    this.onStartPrep,
    this.onMarkReady,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<KitchenOrderCard> {
  bool _isHovered = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute to keep time fresh
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const SizedBox.shrink();

    final firstTask = widget.tasks.first;
    final orderId = firstTask.orderId;
    final shortId = orderId.length > 4
        ? orderId.substring(orderId.length - 4).toUpperCase()
        : orderId.padLeft(4, '0');

    // Determine status from tasks
    final anyInProgress = widget.tasks.any(
      (t) => t.status.toUpperCase() == 'IN_PROGRESS',
    );
    final allQueued = widget.tasks.every(
      (t) => t.status.toUpperCase() == 'QUEUED',
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? Colors.grey.shade300 : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Order ID + Badge + Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Order ID
                  Text(
                    '#$shortId',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Priority Badge
                  if (firstTask.orderType?.toLowerCase() == 'vip')
                    _buildPriorityBadge('VIP', const Color(0xFFDC2626))
                  else if (_getElapsedMinutes() > 15)
                    _buildPriorityBadge('RUSH', const Color(0xFFF97316)),
                  const Spacer(),
                  // Time
                  _buildTimeDisplay(),
                ],
              ),
              const SizedBox(height: 10),

              // Sub-header: Type | Table | KOT
              Row(
                children: [
                  _buildTypeBadge(
                    firstTask.orderType?.toLowerCase() ?? 'dine_in',
                  ),
                  if (firstTask.tableNumber != null &&
                      firstTask.tableNumber!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      'T-${firstTask.tableNumber}',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KOT-$shortId',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Divider
              Container(height: 1, color: Colors.grey.shade100),

              const SizedBox(height: 16),

              // Items List
              ...widget.tasks
                  .take(4)
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${task.quantity}×',
                                style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  task.menuItemName,
                                  style: GoogleFonts.sora(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Special instructions (if any)
                          if (task.specialInstructions != null &&
                              task.specialInstructions!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 26, top: 4),
                              child: Text(
                                task.specialInstructions!,
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFF97316),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

              if (widget.tasks.length > 4)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '+${widget.tasks.length - 4} more items',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),

              // Spacer to push button to bottom
              const Spacer(),

              // Action Button
              if (allQueued)
                _ActionButton(
                  label: 'Start',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFFDC2626),
                  onTap: widget.onStartPrep,
                  isLoading: widget.isLoading,
                )
              else if (anyInProgress)
                _ActionButton(
                  label: 'Ready',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF10B981),
                  onTap: widget.onMarkReady,
                  isLoading: widget.isLoading,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final minutes = _getElapsedMinutes();
    final color = _getTimeColor(minutes);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _formatElapsedTime(),
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isDelivery = type == 'delivery';
    final isTakeaway = type == 'takeaway';

    Color bg;
    Color text;
    String label;

    if (isDelivery) {
      bg = const Color(0xFFDBEAFE);
      text = const Color(0xFF2563EB);
      label = 'delivery';
    } else if (isTakeaway) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
      label = 'takeaway';
    } else {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      label = 'dine in';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  int _getElapsedMinutes() {
    final startTime = widget.tasks.isEmpty
        ? DateTime.now()
        : (widget.tasks.first.startedAt ?? widget.tasks.first.updatedAt);
    return DateTime.now().difference(startTime).inMinutes;
  }

  String _formatElapsedTime() {
    final minutes = _getElapsedMinutes();
    if (minutes >= 1440) {
      return '${minutes ~/ 1440}d';
    } else if (minutes >= 60) {
      return '${minutes ~/ 60}h';
    }
    return '${minutes}m';
  }

  Color _getTimeColor(int minutes) {
    if (minutes >= KitchenConfig.criticalPrepThreshold) {
      return const Color(0xFFDC2626); // Red
    } else if (minutes >= 15) {
      return const Color(0xFFD97706); // Orange
    }
    return const Color(0xFF10B981); // Green for fresh orders
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              elevation: _isHovered ? 6 : 2,
              shadowColor: widget.color.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
