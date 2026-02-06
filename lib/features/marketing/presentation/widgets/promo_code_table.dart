import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

/// Promo code table widget matching the UI design
class PromoCodeTable extends StatelessWidget {
  final List<PromoCodeModel> promoCodes;
  final Function(PromoCodeModel)? onEditTap;
  final Function(PromoCodeModel)? onStatusToggle;
  final String? actionInProgressId;

  const PromoCodeTable({
    super.key,
    required this.promoCodes,
    this.onEditTap,
    this.onStatusToggle,
    this.actionInProgressId,
  });

  @override
  Widget build(BuildContext context) {
    if (promoCodes.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: promoCodes.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                return _PromoCodeRow(
                  promoCode: promoCodes[index],
                  onEditTap: () => onEditTap?.call(promoCodes[index]),
                  onStatusToggle: () => onStatusToggle?.call(promoCodes[index]),
                  isLoading: actionInProgressId == promoCodes[index].id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFFAFAFA),
      child: Row(
        children: [
          const Expanded(flex: 2, child: _HeaderCell(text: 'Code')),
          const Expanded(flex: 2, child: _HeaderCell(text: 'Discount')),
          const Expanded(flex: 2, child: _HeaderCell(text: 'Min Order')),
          const Expanded(flex: 1, child: _HeaderCell(text: 'Uses')),
          const Expanded(flex: 2, child: _HeaderCell(text: 'Status')),
          const Expanded(flex: 2, child: _HeaderCell(text: 'Actions')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'No promo codes found',
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first promo code to get started',
            style: AirMenuTextStyle.small.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AirMenuTextStyle.small.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }
}

class _PromoCodeRow extends StatefulWidget {
  final PromoCodeModel promoCode;
  final VoidCallback? onEditTap;
  final VoidCallback? onStatusToggle;
  final bool isLoading;

  const _PromoCodeRow({
    required this.promoCode,
    this.onEditTap,
    this.onStatusToggle,
    this.isLoading = false,
  });

  @override
  State<_PromoCodeRow> createState() => _PromoCodeRowState();
}

class _PromoCodeRowState extends State<_PromoCodeRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovered ? const Color(0xFFFAFAFA) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Code column
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '%',
                      style: TextStyle(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.promoCode.code,
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Discount column
            Expanded(
              flex: 2,
              child: Text(
                widget.promoCode.discountDisplay,
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Min Order column
            Expanded(
              flex: 2,
              child: Text(
                widget.promoCode.minOrderDisplay,
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            // Uses column
            Expanded(
              flex: 1,
              child: Text(
                widget.promoCode.usesDisplay,
                style: AirMenuTextStyle.normal.copyWith(
                  color: const Color(0xFF1C1C1C),
                ),
              ),
            ),
            // Status column
            Expanded(flex: 2, child: _buildStatusBadge()),
            // Actions column
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onEditTap,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                    tooltip: 'Edit',
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = widget.promoCode.isActive;
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final bgColor = isActive
        ? const Color(0xFF10B981).withOpacity(0.1)
        : const Color(0xFFF59E0B).withOpacity(0.1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                widget.promoCode.status,
                style: AirMenuTextStyle.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final isActive = widget.promoCode.isActive;

    if (widget.isLoading) {
      return SizedBox(
        width: 70,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? const Color(0xFF6B7280) : const Color(0xFF10B981),
              ),
            ),
          ),
        ),
      );
    }

    if (isActive) {
      return OutlinedButton(
        onPressed: widget.onStatusToggle,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: Colors.white,
        ),
        child: Text(
          'Pause',
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: widget.onStatusToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          'Activate',
          style: AirMenuTextStyle.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}

/// Skeleton loader for promo code table
class PromoCodeTableSkeleton extends StatelessWidget {
  const PromoCodeTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header skeleton
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFAFAFA),
            child: Row(
              children: List.generate(
                6,
                (_) => Expanded(child: _shimmerBox(60, 14, 4)),
              ),
            ),
          ),
          const Divider(height: 1),
          // Row skeletons
          ...List.generate(
            5,
            (_) => Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  6,
                  (i) => Expanded(child: _shimmerBox(i == 5 ? 80 : 50, 14, 4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
