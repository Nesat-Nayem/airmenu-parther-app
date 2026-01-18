import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/refund_policy/data/models/refund_policy_model.dart';
import 'package:either_dart/either.dart';

abstract class RefundPolicyRepository {
  Future<Either<Failure, RefundPolicyModel>> getRefundPolicy();
  Future<Either<Failure, RefundPolicyModel>> updateRefundPolicy(String content);
  Future<Either<Failure, RefundPolicyModel>> generateRefundPolicy(
    String platformName,
  );
}
