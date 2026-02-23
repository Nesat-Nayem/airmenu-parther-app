part of 'menu_cubit.dart';

enum MenuViewMode { grid, list }

class MenuState extends Equatable {
  final MenuViewMode viewMode;
  final String selectedCategoryId;
  final String searchQuery;

  const MenuState({
    this.viewMode = MenuViewMode.grid,
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
  });

  MenuState copyWith({
    MenuViewMode? viewMode,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return MenuState(
      viewMode: viewMode ?? this.viewMode,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [viewMode, selectedCategoryId, searchQuery];
}
