import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetKitchenQueueUseCase {
  final KitchenRepository _repository;

  GetKitchenQueueUseCase(this._repository);

  Future<Either<Failure, List<KitchenTaskModel>>> call({
    required String hotelId,
    String? stationId,
    String? status,
  }) {
    return _repository.getKitchenQueue(
      hotelId: hotelId,
      stationId: stationId,
      status: status,
    );
  }
}
