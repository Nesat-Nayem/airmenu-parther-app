import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/data/models/privacy_policy_model.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/repositories/privacy_policy_repository.dart';
import 'package:either_dart/either.dart';

class GetPrivacyPolicyUsecase implements UseCaseNoInput<PrivacyPolicyModel> {
  final PrivacyPolicyRepository repository;

  GetPrivacyPolicyUsecase(this.repository);

  @override
  Future<Either<Failure, PrivacyPolicyModel>> invoke() async {
    return await repository.getPrivacyPolicy();
  }
}
