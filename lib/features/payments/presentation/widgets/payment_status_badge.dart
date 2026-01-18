import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';

class PaymentStatusBadge extends StatelessWidget {
  final SettlementStatus? settlementStatus;
  final DisputeStatus? disputeStatus;

  const PaymentStatusBadge({
    super.key,
    this.settlementStatus,
    this.disputeStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    Color bgColor;

    if (settlementStatus != null) {
      switch (settlementStatus!) {
        case SettlementStatus.pending:
          color = const Color(0xFFF59E0B);
          label = 'pending';
          bgColor = const Color(0xFFFFF7ED);
          break;
        case SettlementStatus.processing:
          color = const Color(0xFF6B7280);
          label = 'processing';
          bgColor = const Color(0xFFF3F4F6);
          break;
        case SettlementStatus.completed:
          color = const Color(0xFF10B981);
          label = 'completed';
          bgColor = const Color(0xFFECFDF5);
          break;
        case SettlementStatus.failed:
          color = const Color(0xFFEF4444);
          label = 'failed';
          bgColor = const Color(0xFFFEF2F2);
          break;
      }
    } else if (disputeStatus != null) {
      switch (disputeStatus!) {
        case DisputeStatus.open:
          color = const Color(0xFFEF4444);
          label = 'open';
          bgColor = const Color(0xFFFEF2F2);
          break;
        case DisputeStatus.resolved:
          color = const Color(0xFF10B981);
          label = 'resolved';
          bgColor = const Color(0xFFECFDF5);
          break;
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AirMenuTextStyle.tiny.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
