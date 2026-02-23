import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/get_terms_conditions_usecase.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/update_terms_conditions_usecase.dart';
import 'package:airmenuai_partner_app/features/terms_conditions/domain/usecases/generate_terms_conditions_usecase.dart';

part 'terms_conditions_event.dart';
part 'terms_conditions_state.dart';

class TermsConditionsBloc
    extends Bloc<TermsConditionsEvent, TermsConditionsState> {
  final GetTermsConditionsUsecase getTermsConditionsUsecase;
  final UpdateTermsConditionsUsecase updateTermsConditionsUsecase;
  final GenerateTermsConditionsUsecase generateTermsConditionsUsecase;

  TermsConditionsBloc({
    required this.getTermsConditionsUsecase,
    required this.updateTermsConditionsUsecase,
    required this.generateTermsConditionsUsecase,
  }) : super(TermsConditionsInitial()) {
    on<LoadTermsConditions>(_onLoadTermsConditions);
    on<UpdateTermsConditions>(_onUpdateTermsConditions);
    on<GenerateTermsConditions>(_onGenerateTermsConditions);
    on<UpdateLocalContent>(_onUpdateLocalContent);
  }

  Future<void> _onLoadTermsConditions(
    LoadTermsConditions event,
    Emitter<TermsConditionsState> emit,
  ) async {
    emit(TermsConditionsLoading());
    try {
      final result = await getTermsConditionsUsecase.invoke();
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to load terms & conditions';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(TermsConditionsError(errorMessage));
        return;
      }
      final policy = result.right;
      if (policy.content.isEmpty) {
        emit(TermsConditionsEmpty('No terms & conditions found'));
        return;
      }
      emit(TermsConditionsLoaded(policy.content));
    } catch (e) {
      emit(TermsConditionsError(e.toString()));
    }
  }

  Future<void> _onUpdateTermsConditions(
    UpdateTermsConditions event,
    Emitter<TermsConditionsState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';
    if (currentState is TermsConditionsLoaded) {
      currentContent = currentState.content;
    }
    emit(TermsConditionsUpdating(event.content));
    try {
      final result = await updateTermsConditionsUsecase.invoke(event.content);
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to update terms & conditions';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(TermsConditionsError(errorMessage));
        if (currentContent.isNotEmpty) {
          emit(TermsConditionsLoaded(currentContent));
        }
        return;
      }
      final policy = result.right;
      emit(
        TermsConditionsUpdated(
          policy.content,
          'Terms & conditions updated successfully',
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      emit(TermsConditionsLoaded(policy.content));
    } catch (e) {
      emit(TermsConditionsError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(TermsConditionsLoaded(currentContent));
      }
    }
  }

  Future<void> _onGenerateTermsConditions(
    GenerateTermsConditions event,
    Emitter<TermsConditionsState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';
    if (currentState is TermsConditionsLoaded) {
      currentContent = currentState.content;
    }
    emit(TermsConditionsGenerating(currentContent));
    try {
      final result = await generateTermsConditionsUsecase.invoke(
        event.platformName,
      );
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to generate terms & conditions';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(TermsConditionsError(errorMessage));
        if (currentContent.isNotEmpty) {
          emit(TermsConditionsLoaded(currentContent));
        }
        return;
      }
      final policy = result.right;
      emit(TermsConditionsLoaded(policy.content));
    } catch (e) {
      emit(TermsConditionsError(e.toString()));
      if (currentContent.isNotEmpty) {
        emit(TermsConditionsLoaded(currentContent));
      }
    }
  }

  void _onUpdateLocalContent(
    UpdateLocalContent event,
    Emitter<TermsConditionsState> emit,
  ) {
    emit(TermsConditionsLoaded(event.content));
  }
}
