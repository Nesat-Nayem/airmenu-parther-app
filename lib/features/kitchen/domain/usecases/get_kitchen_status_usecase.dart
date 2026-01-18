import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetKitchenStatusUseCase {
  final KitchenRepository _repository;

  GetKitchenStatusUseCase(this._repository);

  Future<Either<Failure, KitchenStatusModel>> call(String hotelId) {
    return _repository.getKitchenStatus(hotelId);
  }
}
