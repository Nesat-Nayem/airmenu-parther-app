import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/core/use_case/use_case.dart';
import 'package:airmenuai_partner_app/features/help_support/data/models/help_support_model.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/repositories/help_support_repository.dart';
import 'package:either_dart/either.dart';

class GetHelpSupportUsecase implements UseCaseNoInput<HelpSupportModel> {
  final HelpSupportRepository repository;
  GetHelpSupportUsecase(this.repository);
  @override
  Future<Either<Failure, HelpSupportModel>> invoke() async =>
      await repository.getHelpSupport();
}
