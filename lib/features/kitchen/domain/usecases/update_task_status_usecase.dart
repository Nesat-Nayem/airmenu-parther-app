import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateTaskStatusUseCase {
  final KitchenRepository _repository;

  UpdateTaskStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String taskId,
    required String status,
  }) {
    return _repository.updateTaskStatus(taskId: taskId, status: status);
  }
}
