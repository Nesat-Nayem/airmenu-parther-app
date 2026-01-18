import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';

/// Enum for load status
enum LandmarkLoadStatus { initial, loading, loaded, error }

/// Base state for Landmark feature
class LandmarkState extends Equatable {
  final LandmarkLoadStatus status;
  final List<MallModel> malls;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final String? successMessage;

  const LandmarkState({
    this.status = LandmarkLoadStatus.initial,
    this.malls = const [],
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Create a copy of the state with updated values
  LandmarkState copyWith({
    LandmarkLoadStatus? status,
    List<MallModel>? malls,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LandmarkState(
      status: status ?? this.status,
      malls: malls ?? this.malls,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    malls,
    searchQuery,
    currentPage,
    totalPages,
    hasMore,
    isLoadingMore,
    isCreating,
    isUpdating,
    isDeleting,
    errorMessage,
    successMessage,
  ];
}
