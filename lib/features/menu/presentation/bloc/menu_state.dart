part of 'menu_cubit.dart';

enum MenuViewMode { grid, list }

class MenuState extends Equatable {
  final MenuViewMode viewMode;
  final String selectedCategoryId;
  final String searchQuery;
  final String? hotelId;
  final bool isLoadingHotel;
  final String? hotelError;

  const MenuState({
    this.viewMode = MenuViewMode.list,
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.hotelId,
    this.isLoadingHotel = false,
    this.hotelError,
  });

  MenuState copyWith({
    MenuViewMode? viewMode,
    String? selectedCategoryId,
    String? searchQuery,
    String? hotelId,
    bool? isLoadingHotel,
    String? hotelError,
    bool clearError = false,
  }) {
    return MenuState(
      viewMode: viewMode ?? this.viewMode,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      hotelId: hotelId ?? this.hotelId,
      isLoadingHotel: isLoadingHotel ?? this.isLoadingHotel,
      hotelError: clearError ? null : (hotelError ?? this.hotelError),
    );
  }

  @override
  List<Object?> get props => [viewMode, selectedCategoryId, searchQuery, hotelId, isLoadingHotel, hotelError];
}
