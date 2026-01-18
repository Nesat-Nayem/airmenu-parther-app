import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetReadyOrdersUseCase {
  final KitchenRepository _repository;

  GetReadyOrdersUseCase(this._repository);

  Future<Either<Failure, List<OrderModel>>> call(String hotelId) async {
    return await _repository.getReadyOrders(hotelId);
  }
}
