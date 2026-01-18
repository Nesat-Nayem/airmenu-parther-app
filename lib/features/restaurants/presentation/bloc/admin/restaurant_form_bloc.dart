import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/repositories/admin_restaurants_repository.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/restaurant_form_event.dart';
import 'package:airmenuai_partner_app/features/restaurants/presentation/bloc/admin/restaurant_form_state.dart';

class RestaurantFormBloc
    extends Bloc<RestaurantFormEvent, RestaurantFormState> {
  final AdminRestaurantsRepository _repository;

  RestaurantFormBloc(this._repository) : super(RestaurantFormInitial()) {
    on<CreateRestaurantEvent>(_onCreateRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
  }

  Future<void> _onCreateRestaurant(
    CreateRestaurantEvent event,
    Emitter<RestaurantFormState> emit,
  ) async {
    emit(RestaurantFormLoading());
    try {
      await _repository.createRestaurant(
        data: event.formModel.toJson(),
        imagePath: event.imageFile?.path,
      );
      emit(const RestaurantFormSuccess('Restaurant created successfully!'));
    } catch (e) {
      emit(RestaurantFormFailure(e.toString()));
    }
  }

  Future<void> _onUpdateRestaurant(
    UpdateRestaurantEvent event,
    Emitter<RestaurantFormState> emit,
  ) async {
    emit(RestaurantFormLoading());
    try {
      await _repository.updateRestaurant(
        id: event.restaurantId,
        data: event.formModel.toJson(),
        imagePath: event.imageFile?.path,
      );
      emit(const RestaurantFormSuccess('Restaurant updated successfully!'));
    } catch (e) {
      emit(RestaurantFormFailure(e.toString()));
    }
  }
}
