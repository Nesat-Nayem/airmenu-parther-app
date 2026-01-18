import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/get_refund_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/update_refund_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/refund_policy/domain/usecases/generate_refund_policy_usecase.dart';

part 'refund_policy_event.dart';
part 'refund_policy_state.dart';

class RefundPolicyBloc extends Bloc<RefundPolicyEvent, RefundPolicyState> {
  final GetRefundPolicyUsecase getRefundPolicyUsecase;
  final UpdateRefundPolicyUsecase updateRefundPolicyUsecase;
  final GenerateRefundPolicyUsecase generateRefundPolicyUsecase;

  RefundPolicyBloc({
    required this.getRefundPolicyUsecase,
    required this.updateRefundPolicyUsecase,
    required this.generateRefundPolicyUsecase,
  }) : super(RefundPolicyInitial()) {
    on<LoadRefundPolicy>(_onLoadRefundPolicy);
    on<UpdateRefundPolicy>(_onUpdateRefundPolicy);
    on<GenerateRefundPolicy>(_onGenerateRefundPolicy);
    on<UpdateLocalContent>(_onUpdateLocalContent);
  }

  Future<void> _onLoadRefundPolicy(
    LoadRefundPolicy event,
    Emitter<RefundPolicyState> emit,
  ) async {
    emit(RefundPolicyLoading());

    try {
      final result = await getRefundPolicyUsecase.invoke();

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to load refund policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(RefundPolicyError(errorMessage));
        return;
      }

      final policy = result.right;

      if (policy.content.isEmpty) {
        emit(RefundPolicyEmpty('No refund policy found'));
        return;
      }

      emit(RefundPolicyLoaded(policy.content));
    } catch (e) {
      emit(RefundPolicyError(e.toString()));
    }
  }

  Future<void> _onUpdateRefundPolicy(
    UpdateRefundPolicy event,
    Emitter<RefundPolicyState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';

    if (currentState is RefundPolicyLoaded) {
      currentContent = currentState.content;
    }

    emit(RefundPolicyUpdating(event.content));

    try {
      final result = await updateRefundPolicyUsecase.invoke(event.content);

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to update refund policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(RefundPolicyError(errorMessage));
        if (currentContent.isNotEmpty) {
          emit(RefundPolicyLoaded(currentContent));
        }
        return;
      }

      final policy = result.right;
      emit(
        RefundPolicyUpdated(
          policy.content,
          'Refund policy updated successfully',
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      emit(RefundPolicyLoaded(policy.content));
    } catch (e) {
      emit(RefundPolicyError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(RefundPolicyLoaded(currentContent));
      }
    }
  }

  Future<void> _onGenerateRefundPolicy(
    GenerateRefundPolicy event,
    Emitter<RefundPolicyState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';

    if (currentState is RefundPolicyLoaded) {
      currentContent = currentState.content;
    }

    emit(RefundPolicyGenerating(currentContent));

    try {
      final result = await generateRefundPolicyUsecase.invoke(
        event.platformName,
      );

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to generate refund policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(RefundPolicyError(errorMessage));
        if (currentContent.isNotEmpty) {
          emit(RefundPolicyLoaded(currentContent));
        }
        return;
      }

      final policy = result.right;
      emit(RefundPolicyLoaded(policy.content));
    } catch (e) {
      emit(RefundPolicyError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(RefundPolicyLoaded(currentContent));
      }
    }
  }

  void _onUpdateLocalContent(
    UpdateLocalContent event,
    Emitter<RefundPolicyState> emit,
  ) {
    emit(RefundPolicyLoaded(event.content));
  }
}
