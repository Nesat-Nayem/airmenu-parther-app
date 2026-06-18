import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/pricing/data/models/pricing_plan_model.dart';
import 'package:airmenuai_partner_app/features/pricing/data/repositories/pricing_repository.dart';

enum PricingStatus { initial, loading, loaded, error }

class PricingState extends Equatable {
  final PricingStatus status;
  final List<PricingPlanModel> plans;
  final String? errorMessage;
  final String? successMessage;

  const PricingState({
    this.status = PricingStatus.initial,
    this.plans = const [],
    this.errorMessage,
    this.successMessage,
  });

  PricingState copyWith({
    PricingStatus? status,
    List<PricingPlanModel>? plans,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return PricingState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [status, plans, errorMessage, successMessage];
}

sealed class PricingEvent extends Equatable {
  const PricingEvent();
  @override
  List<Object?> get props => [];
}

class LoadPricingPlans extends PricingEvent {
  const LoadPricingPlans();
}

class CreatePricingPlan extends PricingEvent {
  final PricingPlanModel plan;
  const CreatePricingPlan(this.plan);
  @override
  List<Object?> get props => [plan];
}

class UpdatePricingPlan extends PricingEvent {
  final String id;
  final Map<String, dynamic> body;
  const UpdatePricingPlan(this.id, this.body);
  @override
  List<Object?> get props => [id, body];
}

class DeletePricingPlan extends PricingEvent {
  final String id;
  const DeletePricingPlan(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearPricingMessage extends PricingEvent {
  const ClearPricingMessage();
}

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final PricingRepository _repository;

  PricingBloc(this._repository) : super(const PricingState()) {
    on<LoadPricingPlans>(_onLoad);
    on<CreatePricingPlan>(_onCreate);
    on<UpdatePricingPlan>(_onUpdate);
    on<DeletePricingPlan>(_onDelete);
    on<ClearPricingMessage>((_, emit) => emit(state.copyWith(clearMessages: true)));
  }

  Future<void> _onLoad(LoadPricingPlans event, Emitter<PricingState> emit) async {
    emit(state.copyWith(status: PricingStatus.loading, clearMessages: true));
    try {
      final plans = await _repository.getPlans();
      emit(state.copyWith(status: PricingStatus.loaded, plans: plans));
    } catch (e) {
      emit(state.copyWith(status: PricingStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(CreatePricingPlan event, Emitter<PricingState> emit) async {
    try {
      await _repository.createPlan(event.plan);
      final plans = await _repository.getPlans();
      emit(state.copyWith(
        status: PricingStatus.loaded,
        plans: plans,
        successMessage: 'Pricing plan created',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdatePricingPlan event, Emitter<PricingState> emit) async {
    try {
      await _repository.updatePlan(event.id, event.body);
      final plans = await _repository.getPlans();
      emit(state.copyWith(
        status: PricingStatus.loaded,
        plans: plans,
        successMessage: 'Pricing plan updated',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDelete(DeletePricingPlan event, Emitter<PricingState> emit) async {
    try {
      await _repository.deletePlan(event.id);
      final plans = await _repository.getPlans();
      emit(state.copyWith(
        status: PricingStatus.loaded,
        plans: plans,
        successMessage: 'Pricing plan deleted',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
