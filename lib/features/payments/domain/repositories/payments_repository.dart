import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';

abstract class PaymentsRepository {
  Future<PaymentStatsEntity> getPaymentStats();
  Future<List<SettlementEntity>> getSettlements({String? filter});
  Future<List<DisputeEntity>> getDisputes({String? filter});
}
