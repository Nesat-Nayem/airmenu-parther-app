import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/data/models/terms_conditions_model.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/repositories/terms_conditions_repository.dart';
import 'package:either_dart/either.dart';

class UpdateTermsConditionsUsecase
    implements UseCaseOneInput<String, TermsConditionsModel> {
  final TermsConditionsRepository repository;

  UpdateTermsConditionsUsecase(this.repository);

  @override
  Future<Either<Failure, TermsConditionsModel>> invoke(String content) async {
    return await repository.updateTermsConditions(content);
  }
}
