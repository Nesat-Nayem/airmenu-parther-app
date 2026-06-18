import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/models/trial_code_model.dart';
import 'package:airmenuai_partner_app/features/trial_codes/data/repositories/trial_code_repository.dart';

enum TrialCodeStatus { initial, loading, loaded, error }

class TrialCodeState extends Equatable {
  final TrialCodeStatus status;
  final List<TrialCodeModel> codes;
  final String? errorMessage;
  final String? successMessage;

  const TrialCodeState({
    this.status = TrialCodeStatus.initial,
    this.codes = const [],
    this.errorMessage,
    this.successMessage,
  });

  TrialCodeState copyWith({
    TrialCodeStatus? status,
    List<TrialCodeModel>? codes,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return TrialCodeState(
      status: status ?? this.status,
      codes: codes ?? this.codes,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [status, codes, errorMessage, successMessage];
}

sealed class TrialCodeEvent extends Equatable {
  const TrialCodeEvent();
  @override
  List<Object?> get props => [];
}

class LoadTrialCodes extends TrialCodeEvent { const LoadTrialCodes(); }
class CreateTrialCode extends TrialCodeEvent {
  final TrialCodeModel code;
  const CreateTrialCode(this.code);
  @override List<Object?> get props => [code];
}
class UpdateTrialCode extends TrialCodeEvent {
  final String code;
  final Map<String, dynamic> body;
  const UpdateTrialCode(this.code, this.body);
  @override List<Object?> get props => [code, body];
}
class ClearTrialCodeMessage extends TrialCodeEvent { const ClearTrialCodeMessage(); }

class TrialCodeBloc extends Bloc<TrialCodeEvent, TrialCodeState> {
  final TrialCodeRepository _repository;
  TrialCodeBloc(this._repository) : super(const TrialCodeState()) {
    on<LoadTrialCodes>(_onLoad);
    on<CreateTrialCode>(_onCreate);
    on<UpdateTrialCode>(_onUpdate);
    on<ClearTrialCodeMessage>((_, emit) => emit(state.copyWith(clearMessages: true)));
  }

  Future<void> _onLoad(LoadTrialCodes event, Emitter<TrialCodeState> emit) async {
    emit(state.copyWith(status: TrialCodeStatus.loading, clearMessages: true));
    try {
      final codes = await _repository.getCodes();
      emit(state.copyWith(status: TrialCodeStatus.loaded, codes: codes));
    } catch (e) {
      emit(state.copyWith(status: TrialCodeStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(CreateTrialCode event, Emitter<TrialCodeState> emit) async {
    try {
      await _repository.createCode(event.code);
      final codes = await _repository.getCodes();
      emit(state.copyWith(status: TrialCodeStatus.loaded, codes: codes, successMessage: 'Trial code saved'));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTrialCode event, Emitter<TrialCodeState> emit) async {
    try {
      await _repository.updateCode(event.code, event.body);
      final codes = await _repository.getCodes();
      emit(state.copyWith(status: TrialCodeStatus.loaded, codes: codes, successMessage: 'Trial code updated'));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
