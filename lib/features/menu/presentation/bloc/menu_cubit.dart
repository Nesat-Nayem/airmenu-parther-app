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
}
