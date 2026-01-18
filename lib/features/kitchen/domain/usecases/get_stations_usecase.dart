import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetStationsUseCase {
  final KitchenRepository _repository;

  GetStationsUseCase(this._repository);

  Future<Either<Failure, List<KitchenStationModel>>> call(String hotelId) {
    return _repository.getStations(hotelId);
  }
}
