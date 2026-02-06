import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/staff_model.dart';
import 'staff_shimmer.dart';

class StaffDataTable extends StatelessWidget {
  final List<StaffModel> staff;
  final Set<String> loadingIds;
  final Function(StaffModel) onEdit;
  final Function(String) onToggleStatus;
  final Function(String) onDelete;

  const StaffDataTable({
    super.key,
    required this.staff,
    required this.loadingIds,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobileView();
        }
        return _buildDesktopView();
      },
    );
  }

  Widget _buildMobileView() {
    if (staff.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: staff
          .map(
            (s) => _MobileStaffCard(
              staff: s,
              isLoading: loadingIds.contains(s.id),
              onEdit: () => onEdit(s),
              onToggleStatus: () => onToggleStatus(s.id),
              onDelete: () => onDelete(s.id),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDesktopView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Staff Member',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Role',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Contact',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Shift',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: AirMenuTextStyle.small.bold600().withColor(
                      Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 120,
                  child: Text(
                    'Actions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          if (staff.isEmpty)
            _buildEmptyState()
          else
            ...staff.map(
              (s) => _DesktopStaffRow(
                staff: s,
                isLoading: loadingIds.contains(s.id),
                onEdit: () => onEdit(s),
                onToggleStatus: () => onToggleStatus(s.id),
                onDelete: () => onDelete(s.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: GoogleFonts.sora(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// Mobile card view for staff member
class _MobileStaffCard extends StatefulWidget {
  final StaffModel staff;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _MobileStaffCard({
    required this.staff,
    required this.isLoading,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  State<_MobileStaffCard> createState() => _MobileStaffCardState();
}

class _MobileStaffCardState extends State<_MobileStaffCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Status
          Row(
            children: [
              _Avatar(
                initials: widget.staff.initials,
                isActive: widget.staff.isActive,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staff.name,
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.staff.joinedDisplay,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(isActive: widget.staff.isActive),
            ],
          ),
          const SizedBox(height: 16),
          // Contact info
          Row(
            children: [
              Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.staff.email,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                '+91 ${widget.staff.phone}',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Role & Shift
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'Role',
                  value: widget.staff.displayRole,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  label: 'Shift',
                  value: widget.staff.displayShift,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.isLoading
                ? [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ]
                : [
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      color: Colors.grey.shade600,
                      onTap: widget.onEdit,
                      tooltip: 'Edit',
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: widget.staff.isActive
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                      color: Colors.grey.shade600,
                      onTap: widget.onToggleStatus,
                      tooltip: widget.staff.isActive ? 'Disable' : 'Enable',
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFDC2626),
                      onTap: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: value == '-' ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop row with hover animation
class _DesktopStaffRow extends StatefulWidget {
  final StaffModel staff;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _DesktopStaffRow({
    required this.staff,
    required this.isLoading,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  State<_DesktopStaffRow> createState() => _DesktopStaffRowState();
}

class _DesktopStaffRowState extends State<_DesktopStaffRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            // Staff Member
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _Avatar(
                    initials: widget.staff.initials,
                    isActive: widget.staff.isActive,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.staff.name,
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.staff.joinedDisplay,
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Role
            Expanded(
              flex: 2,
              child: Text(
                widget.staff.displayRole,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.staff.displayRole == '-'
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
              ),
            ),
            // Contact
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.staff.email,
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+91 ${widget.staff.phone}',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Shift
            Expanded(
              flex: 1,
              child: Text(
                widget.staff.displayShift,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.staff.displayShift == '-'
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
              ),
            ),
            // Status
            Expanded(
              flex: 1,
              child: _StatusBadge(isActive: widget.staff.isActive),
            ),
            // Actions
            SizedBox(
              width: 120,
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 150),
                          child: _ActionButton(
                            icon: Icons.edit_outlined,
                            color: Colors.grey.shade600,
                            onTap: widget.onEdit,
                            tooltip: 'Edit',
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 150),
                          child: _ActionButton(
                            icon: widget.staff.isActive
                                ? Icons.block_outlined
                                : Icons.check_circle_outline,
                            color: Colors.grey.shade600,
                            onTap: widget.onToggleStatus,
                            tooltip: widget.staff.isActive
                                ? 'Disable'
                                : 'Enable',
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 150),
                          child: _ActionButton(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFDC2626),
                            onTap: widget.onDelete,
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final bool isActive;

  const _Avatar({required this.initials, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFDC2626),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFEA580C),
      const Color(0xFF0284C7),
      const Color(0xFFDB2777),
    ];
    final colorIndex =
        initials.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    final bgColor = colors[colorIndex];

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: bgColor,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF059669).withValues(alpha: 0.1)
            : const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'active' : 'offline',
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for loading state with animation
class StaffDataTableSkeleton extends StatelessWidget {
  const StaffDataTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return ShimmerEffect(
            child: Column(
              children: List.generate(3, (index) => const StaffCardSkeleton()),
            ),
          );
        }

        return ShimmerEffect(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Header skeleton
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: const Row(
                    children: [
                      ShimmerBox(width: 100, height: 14),
                      Spacer(),
                      ShimmerBox(width: 50, height: 14),
                      Spacer(),
                      ShimmerBox(width: 70, height: 14),
                      Spacer(),
                      ShimmerBox(width: 40, height: 14),
                      Spacer(),
                      ShimmerBox(width: 50, height: 14),
                      SizedBox(width: 120),
                    ],
                  ),
                ),
                // Row skeletons
                ...List.generate(4, (index) => const StaffRowSkeleton()),
              ],
            ),
          ),
        );
      },
    );
  }
}
