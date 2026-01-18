import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:airmenuai_partner_app/core/models/generic_response.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetOrdersUseCase {
  final OrdersRepository _ordersRepository;

  GetOrdersUseCase(this._ordersRepository);

  /// Get all orders (pagination removed - to be implemented later)
  Future<Either<Failure, GenericResponse<List<OrderModel>>>> call({
    String? status,
    String? paymentStatus,
  }) {
    return _ordersRepository.getOrders(
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}
