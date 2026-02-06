class PaymentStatsEntity {
  final double pendingSettlements;
  final double processedToday;
  final String avgSettlementTime;
  final int openDisputes;
  final double processedGrowth; // e.g. 15% vs yesterday

  const PaymentStatsEntity({
    required this.pendingSettlements,
    required this.processedToday,
    required this.avgSettlementTime,
    required this.openDisputes,
    required this.processedGrowth,
  });
}

class SettlementEntity {
  final String id;
  final String restaurantName;
  final String period; // e.g. Dec 1-7, 2024
  final int ordersCount;
  final double amount;
  final DateTime dueDate;
  final SettlementStatus status;

  const SettlementEntity({
    required this.id,
    required this.restaurantName,
    required this.period,
    required this.ordersCount,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

enum SettlementStatus { pending, processing, completed, failed }

class DisputeEntity {
  final String id;
  final String restaurantName;
  final String reason; // e.g. Order cancellation refund
  final double amount;
  final DateTime date;
  final DisputeStatus status;

  const DisputeEntity({
    required this.id,
    required this.restaurantName,
    required this.reason,
    required this.amount,
    required this.date,
    required this.status,
  });
}

enum DisputeStatus { open, resolved }

class PaymentBottomStatsEntity {
  final double thisMonthSettled;
  final double trendPercentage;
  final double pendingAmount;
  final String pendingDueText;
  final double disputeAmount;
  final int disputeCount;

  const PaymentBottomStatsEntity({
    required this.thisMonthSettled,
    required this.trendPercentage,
    required this.pendingAmount,
    required this.pendingDueText,
    required this.disputeAmount,
    required this.disputeCount,
  });
}
