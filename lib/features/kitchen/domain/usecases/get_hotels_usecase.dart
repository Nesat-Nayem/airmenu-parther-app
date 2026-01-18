import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/data/models/hotel_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case to get vendor's hotels for hotel selection in Kitchen Panel
class GetHotelsUseCase {
  final KitchenRepository _repository;

  GetHotelsUseCase(this._repository);

  Future<Either<Failure, List<HotelModel>>> call() async {
    return _repository.getHotels();
  }
}
