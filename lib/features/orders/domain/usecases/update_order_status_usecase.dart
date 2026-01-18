import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrderStatusUseCase {
  final OrdersRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String status,
  }) {
    return _repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
