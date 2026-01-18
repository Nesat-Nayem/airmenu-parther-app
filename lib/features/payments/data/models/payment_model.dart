import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';

class PaymentStatsModel extends PaymentStatsEntity {
  const PaymentStatsModel({
    required super.pendingSettlements,
    required super.processedToday,
    required super.avgSettlementTime,
    required super.openDisputes,
    required super.processedGrowth,
  });
}

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.restaurantName,
    required super.period,
    required super.ordersCount,
    required super.amount,
    required super.dueDate,
    required super.status,
  });
}

class DisputeModel extends DisputeEntity {
  const DisputeModel({
    required super.id,
    required super.restaurantName,
    required super.reason,
    required super.amount,
    required super.date,
    required super.status,
  });
}
