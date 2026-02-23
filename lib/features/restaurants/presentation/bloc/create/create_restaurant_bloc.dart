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
    on<SubmitRestaurantWithImage>(_onSubmitRestaurantWithImage);
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

  Future<void> _onSubmitRestaurantWithImage(
    SubmitRestaurantWithImage event,
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
      // Build the data map for the API
      final data = <String, dynamic>{
        'name': event.name,
        'cuisine': event.cuisine,
        'description': event.description,
        'location': event.location,
        'price': event.price,
        'distance': '0 km',
        'weeklyTimings': event.weeklyTimings.map((t) => t.toJson()).toList(),
      };

      // Don't send coordinates field at all if we don't have valid data
      // The backend will handle it as optional
      if (event.googlePlaceId != null && event.googlePlaceId!.isNotEmpty) {
        data['googlePlaceId'] = event.googlePlaceId;
      }
      
      if (event.rating != null) {
        data['rating'] = event.rating;
      }
      if (event.offer != null && event.offer!.isNotEmpty) {
        data['offer'] = event.offer;
      }
      if (event.cgstRate != null) {
        data['cgstRate'] = event.cgstRate;
      }
      if (event.sgstRate != null) {
        data['sgstRate'] = event.sgstRate;
      }
      if (event.serviceCharge != null) {
        data['serviceCharge'] = event.serviceCharge;
      }

      await _repository.createRestaurant(
        data: data,
        imagePath: event.imagePath,
      );

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
