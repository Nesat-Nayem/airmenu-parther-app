import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/get_privacy_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/update_privacy_policy_usecase.dart';
import 'package:airmenuai_partner_app/features/privacy_policy/domain/usecases/generate_privacy_policy_usecase.dart';

part 'privacy_policy_event.dart';
part 'privacy_policy_state.dart';

class PrivacyPolicyBloc extends Bloc<PrivacyPolicyEvent, PrivacyPolicyState> {
  final GetPrivacyPolicyUsecase getPrivacyPolicyUsecase;
  final UpdatePrivacyPolicyUsecase updatePrivacyPolicyUsecase;
  final GeneratePrivacyPolicyUsecase generatePrivacyPolicyUsecase;

  PrivacyPolicyBloc({
    required this.getPrivacyPolicyUsecase,
    required this.updatePrivacyPolicyUsecase,
    required this.generatePrivacyPolicyUsecase,
  }) : super(PrivacyPolicyInitial()) {
    on<LoadPrivacyPolicy>(_onLoadPrivacyPolicy);
    on<UpdatePrivacyPolicy>(_onUpdatePrivacyPolicy);
    on<GeneratePrivacyPolicy>(_onGeneratePrivacyPolicy);
    on<UpdateLocalContent>(_onUpdateLocalContent);
  }

  Future<void> _onLoadPrivacyPolicy(
    LoadPrivacyPolicy event,
    Emitter<PrivacyPolicyState> emit,
  ) async {
    emit(PrivacyPolicyLoading());

    try {
      final result = await getPrivacyPolicyUsecase.invoke();

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to load privacy policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(PrivacyPolicyError(errorMessage));
        return;
      }

      final policy = result.right;

      if (policy.content.isEmpty) {
        emit(PrivacyPolicyEmpty('No privacy policy found'));
        return;
      }

      emit(PrivacyPolicyLoaded(policy.content));
    } catch (e) {
      emit(PrivacyPolicyError(e.toString()));
    }
  }

  Future<void> _onUpdatePrivacyPolicy(
    UpdatePrivacyPolicy event,
    Emitter<PrivacyPolicyState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';

    if (currentState is PrivacyPolicyLoaded) {
      currentContent = currentState.content;
    }

    emit(PrivacyPolicyUpdating(event.content));

    try {
      final result = await updatePrivacyPolicyUsecase.invoke(event.content);

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to update privacy policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(PrivacyPolicyError(errorMessage));
        // Restore previous content
        if (currentContent.isNotEmpty) {
          emit(PrivacyPolicyLoaded(currentContent));
        }
        return;
      }

      final policy = result.right;
      emit(
        PrivacyPolicyUpdated(
          policy.content,
          'Privacy policy updated successfully',
        ),
      );

      // After showing success message, return to loaded state
      await Future.delayed(const Duration(seconds: 2));
      emit(PrivacyPolicyLoaded(policy.content));
    } catch (e) {
      emit(PrivacyPolicyError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(PrivacyPolicyLoaded(currentContent));
      }
    }
  }

  Future<void> _onGeneratePrivacyPolicy(
    GeneratePrivacyPolicy event,
    Emitter<PrivacyPolicyState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';

    if (currentState is PrivacyPolicyLoaded) {
      currentContent = currentState.content;
    }

    emit(PrivacyPolicyGenerating(currentContent));

    try {
      final result = await generatePrivacyPolicyUsecase.invoke(
        event.platformName,
      );

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to generate privacy policy';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(PrivacyPolicyError(errorMessage));
        // Restore previous content
        if (currentContent.isNotEmpty) {
          emit(PrivacyPolicyLoaded(currentContent));
        }
        return;
      }

      final policy = result.right;
      emit(PrivacyPolicyLoaded(policy.content));
    } catch (e) {
      emit(PrivacyPolicyError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(PrivacyPolicyLoaded(currentContent));
      }
    }
  }

  void _onUpdateLocalContent(
    UpdateLocalContent event,
    Emitter<PrivacyPolicyState> emit,
  ) {
    // Update local content without API call
    emit(PrivacyPolicyLoaded(event.content));
  }
}
