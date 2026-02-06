import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_restaurants_repository.dart';
import 'create_restaurant_event.dart';
import 'create_restaurant_state.dart';

class CreateRestaurantBloc
    extends Bloc<CreateRestaurantEvent, CreateRestaurantState> {
  final AdminRestaurantsRepository _repository;
  Timer? _debounce;

  CreateRestaurantBloc(this._repository)
    : super(const CreateRestaurantState()) {
    on<UpdateAutocompleteQuery>(_onUpdateAutocompleteQuery);
    on<ClearSuggestions>(_onClearSuggestions);
    on<SubmitRestaurant>(_onSubmitRestaurant);
  }

  Future<void> _onUpdateAutocompleteQuery(
    UpdateAutocompleteQuery event,
    Emitter<CreateRestaurantState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(
        state.copyWith(
          suggestions: [],
          isAutocompleteLoading: false,
          submissionStatus: SubmissionStatus.initial,
        ),
      );
      return;
    }

    // Handle debounce manually if needed, or rely on UI-side debounce.
    // Implementing a simple one here for robustness.
    _debounce?.cancel();

    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      completer.complete();
    });

    await completer.future;

    emit(
      state.copyWith(
        isAutocompleteLoading: true,
        error: () => null,
        suggestions: [],
        submissionStatus: SubmissionStatus.initial,
      ),
    );

    try {
      final suggestions = await _repository.getAutocompleteSuggestions(
        event.query,
      );
      emit(
        state.copyWith(suggestions: suggestions, isAutocompleteLoading: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAutocompleteLoading: false,
          error: () => e.toString(),
          submissionStatus: SubmissionStatus.initial,
        ),
      );
    }
  }

  void _onClearSuggestions(
    ClearSuggestions event,
    Emitter<CreateRestaurantState> emit,
  ) {
    emit(state.copyWith(suggestions: []));
  }

  Future<void> _onSubmitRestaurant(
    SubmitRestaurant event,
    Emitter<CreateRestaurantState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: SubmissionStatus.loading,
        suggestions: [],
        isAutocompleteLoading: false,
        error: null,
        successMessage: null,
      ),
    );

    try {
      await _repository.createRestaurant(data: event.request.toJson());
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.success,
          successMessage: () => 'Restaurant created successfully!',
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          error: () => e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
