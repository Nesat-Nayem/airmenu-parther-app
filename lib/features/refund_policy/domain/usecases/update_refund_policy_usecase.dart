import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/refund_policy/data/models/refund_policy_model.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/repositories/refund_policy_repository.dart';
import 'package:either_dart/either.dart';

class UpdateRefundPolicyUsecase
    implements UseCaseOneInput<String, RefundPolicyModel> {
  final RefundPolicyRepository repository;

  UpdateRefundPolicyUsecase(this.repository);

  @override
  Future<Either<Failure, RefundPolicyModel>> invoke(String content) async {
    return await repository.updateRefundPolicy(content);
  }
}
