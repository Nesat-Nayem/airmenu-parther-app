import 'package:airmenuai_partner_app/features/payments/data/models/payment_model.dart';
import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';
import 'package:airmenuai_partner_app/features/payments/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  @override
  Future<PaymentStatsEntity> getPaymentStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return const PaymentStatsModel(
      pendingSettlements: 45.2, // Lakhs
      processedToday: 12.8, // Lakhs
      avgSettlementTime: '2.4 days',
      openDisputes: 12,
      processedGrowth: 15, // 15%
    );
  }

  @override
  Future<List<SettlementEntity>> getSettlements({String? filter}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      SettlementModel(
        id: 'SET-001',
        restaurantName: 'Spice Garden',
        period: 'Dec 1-7, 2024',
        ordersCount: 234,
        amount: 125000,
        dueDate: DateTime(2024, 12, 10),
        status: SettlementStatus.pending,
      ),
      SettlementModel(
        id: 'SET-002',
        restaurantName: 'Pizza Paradise',
        period: 'Dec 1-7, 2024',
        ordersCount: 167,
        amount: 89500,
        dueDate: DateTime(2024, 12, 10),
        status: SettlementStatus.processing,
      ),
      SettlementModel(
        id: 'SET-003',
        restaurantName: 'Biryani Blues',
        period: 'Dec 1-7, 2024',
        ordersCount: 456,
        amount: 234000,
        dueDate: DateTime(2024, 12, 10),
        status: SettlementStatus.completed,
      ),
      SettlementModel(
        id: 'SET-004',
        restaurantName: 'Sushi Station',
        period: 'Dec 1-7, 2024',
        ordersCount: 89,
        amount: 67800,
        dueDate: DateTime(2024, 12, 10),
        status: SettlementStatus.failed,
      ),
      SettlementModel(
        id: 'SET-005',
        restaurantName: 'Burger Barn',
        period: 'Dec 1-7, 2024',
        ordersCount: 312,
        amount: 145200,
        dueDate: DateTime(2024, 12, 10),
        status: SettlementStatus.completed,
      ),
    ];
  }

  @override
  Future<List<DisputeEntity>> getDisputes({String? filter}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      DisputeModel(
        id: 'DIS-001',
        restaurantName: 'Tandoor Express',
        reason: 'Order cancellation refund',
        amount: 4500,
        date: DateTime(2024, 12, 8),
        status: DisputeStatus.open,
      ),
      DisputeModel(
        id: 'DIS-002',
        restaurantName: 'Cafe Coffee Day',
        reason: 'Missing items',
        amount: 2100,
        date: DateTime(2024, 12, 7),
        status: DisputeStatus.resolved,
      ),
      DisputeModel(
        id: 'DIS-003',
        restaurantName: 'Wok This Way',
        reason: 'Delayed delivery compensation',
        amount: 8900,
        date: DateTime(2024, 12, 6),
        status: DisputeStatus.open,
      ),
    ];
  }

  @override
  Future<PaymentBottomStatsEntity> getBottomStats() async {
    await Future.delayed(const Duration(seconds: 1));
    return const PaymentBottomStatsEntity(
      thisMonthSettled: 240000, // ₹2.4Cr
      trendPercentage: 18, // +18% vs last month
      pendingAmount: 45200, // ₹45.2L
      pendingDueText: 'Due in next 3 days',
      disputeAmount: 15500, // ₹15,500
      disputeCount: 3, // 3 open disputes
    );
  }
}
