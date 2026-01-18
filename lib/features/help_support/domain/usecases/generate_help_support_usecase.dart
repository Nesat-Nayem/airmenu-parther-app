import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/help_support/data/models/help_support_model.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/repositories/help_support_repository.dart';
import 'package:either_dart/either.dart';

class GenerateHelpSupportUsecase
    implements UseCaseOneInput<String, HelpSupportModel> {
  final HelpSupportRepository repository;
  GenerateHelpSupportUsecase(this.repository);
  @override
  Future<Either<Failure, HelpSupportModel>> invoke(String platformName) async =>
      await repository.generateHelpSupport(platformName);
}
