import 'package:flutter/material.dart';
import '../../data/models/promo_code_model.dart';
import '../../../../utils/typography/airmenu_typography.dart';

class MobilePromoCodeList extends StatelessWidget {
  final List<PromoCodeModel> promoCodes;
  final Function(PromoCodeModel)? onEditTap;
  final Function(PromoCodeModel)? onStatusToggle;
  final String? actionInProgressId;

  const MobilePromoCodeList({
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: promoCodes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _MobilePromoCodeCard(
          promoCode: promoCodes[index],
          onEditTap: () => onEditTap?.call(promoCodes[index]),
          onStatusToggle: () => onStatusToggle?.call(promoCodes[index]),
          isLoading: actionInProgressId == promoCodes[index].id,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    // Reusing the empty state design from table
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
          const Icon(
            Icons.local_offer_outlined,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'No promo codes found',
            style: AirMenuTextStyle.subheadingH5.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilePromoCodeCard extends StatelessWidget {
  final PromoCodeModel promoCode;
  final VoidCallback? onEditTap;
  final VoidCallback? onStatusToggle;
  final bool isLoading;

  const _MobilePromoCodeCard({
    required this.promoCode,
    this.onEditTap,
    this.onStatusToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '%',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    promoCode.code,
                    style: AirMenuTextStyle.normal.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                'Discount',
                promoCode.discountDisplay,
                const Color(0xFFDC2626),
              ),
              _buildInfoColumn(
                'Min Order',
                promoCode.minOrderDisplay,
                const Color(0xFF6B7280),
              ),
              _buildInfoColumn(
                'Uses',
                promoCode.usesDisplay,
                const Color(0xFF1C1C1C),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        Text(
          value,
          style: AirMenuTextStyle.normal.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = promoCode.isActive;
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        promoCode.status,
        style: AirMenuTextStyle.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isActive = promoCode.isActive;

    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onStatusToggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.white : const Color(0xFF10B981),
        foregroundColor: isActive ? const Color(0xFF6B7280) : Colors.white,
        side: isActive ? const BorderSide(color: Color(0xFFE5E7EB)) : null,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      child: Text(isActive ? 'Pause' : 'Activate'),
    );
  }
}
