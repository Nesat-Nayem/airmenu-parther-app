import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/refund_policy/data/models/refund_policy_model.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/repositories/refund_policy_repository.dart';
import 'package:either_dart/either.dart';

class GetRefundPolicyUsecase implements UseCaseNoInput<RefundPolicyModel> {
  final RefundPolicyRepository repository;

  GetRefundPolicyUsecase(this.repository);

  @override
  Future<Either<Failure, RefundPolicyModel>> invoke() async {
    return await repository.getRefundPolicy();
  }
}
