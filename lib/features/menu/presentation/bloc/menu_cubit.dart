import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit() : super(const MenuState());

  void setViewMode(MenuViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setHotelId(String hotelId) {
    emit(state.copyWith(hotelId: hotelId));
  }

  void setLoading() {
    emit(state.copyWith(isLoadingHotel: true, hotelError: null, clearError: true));
  }

  void setHotelError(String error) {
    emit(state.copyWith(isLoadingHotel: false, hotelError: error));
  }

  void setHotelLoaded(String hotelId) {
    emit(state.copyWith(hotelId: hotelId, isLoadingHotel: false, hotelError: null, clearError: true));
  }
}
