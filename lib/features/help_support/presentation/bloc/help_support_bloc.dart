import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/get_help_support_usecase.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/update_help_support_usecase.dart';
import 'package:airmenuai_partner_app/features/help_support/domain/usecases/generate_help_support_usecase.dart';

part 'help_support_event.dart';
part 'help_support_state.dart';

class HelpSupportBloc extends Bloc<HelpSupportEvent, HelpSupportState> {
  final GetHelpSupportUsecase getHelpSupportUsecase;
  final UpdateHelpSupportUsecase updateHelpSupportUsecase;
  final GenerateHelpSupportUsecase generateHelpSupportUsecase;

  HelpSupportBloc({
    required this.getHelpSupportUsecase,
    required this.updateHelpSupportUsecase,
    required this.generateHelpSupportUsecase,
  }) : super(HelpSupportInitial()) {
    on<LoadHelpSupport>(_onLoadHelpSupport);
    on<UpdateHelpSupport>(_onUpdateHelpSupport);
    on<GenerateHelpSupport>(_onGenerateHelpSupport);
    on<UpdateLocalContent>(_onUpdateLocalContent);
  }

  Future<void> _onLoadHelpSupport(
    LoadHelpSupport event,
    Emitter<HelpSupportState> emit,
  ) async {
    emit(HelpSupportLoading());
    try {
      final result = await getHelpSupportUsecase.invoke();
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to load help & support';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(HelpSupportError(errorMessage));
        return;
      }
      final policy = result.right;
      if (policy.content.isEmpty) {
        emit(HelpSupportEmpty('No help & support found'));
        return;
      }
      emit(HelpSupportLoaded(policy.content));
    } catch (e) {
      emit(HelpSupportError(e.toString()));
    }
  }

  Future<void> _onUpdateHelpSupport(
    UpdateHelpSupport event,
    Emitter<HelpSupportState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';
    if (currentState is HelpSupportLoaded) {
      currentContent = currentState.content;
    }
    emit(HelpSupportUpdating(event.content));
    try {
      final result = await updateHelpSupportUsecase.invoke(event.content);
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to update help & support';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(HelpSupportError(errorMessage));
        if (currentContent.isNotEmpty) emit(HelpSupportLoaded(currentContent));
        return;
      }
      final policy = result.right;
      emit(
        HelpSupportUpdated(
          policy.content,
          'Help & support updated successfully',
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      emit(HelpSupportLoaded(policy.content));
    } catch (e) {
      emit(HelpSupportError(e.toString()));
      if (currentContent.isNotEmpty) emit(HelpSupportLoaded(currentContent));
    }
  }

  Future<void> _onGenerateHelpSupport(
    GenerateHelpSupport event,
    Emitter<HelpSupportState> emit,
  ) async {
    final currentState = state;
    String currentContent = '';
    if (currentState is HelpSupportLoaded) {
      currentContent = currentState.content;
    }
    emit(HelpSupportGenerating(currentContent));
    try {
      final result = await generateHelpSupportUsecase.invoke(
        event.platformName,
      );
      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to generate help & support';
        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }
        emit(HelpSupportError(errorMessage));
        if (currentContent.isNotEmpty) emit(HelpSupportLoaded(currentContent));
        return;
      }
      final policy = result.right;
      emit(HelpSupportLoaded(policy.content));
    } catch (e) {
      emit(HelpSupportError(e.toString()));
      if (currentContent.isNotEmpty) emit(HelpSupportLoaded(currentContent));
    }
  }

  void _onUpdateLocalContent(
    UpdateLocalContent event,
    Emitter<HelpSupportState> emit,
  ) {
    emit(HelpSupportLoaded(event.content));
  }
}
