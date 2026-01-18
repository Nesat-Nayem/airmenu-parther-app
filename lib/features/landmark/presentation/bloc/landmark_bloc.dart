import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/landmark/domain/repositories/i_landmark_repository.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/bloc/landmark_event.dart';
import 'package:airmenuai_partner_app/features/landmark/presentation/bloc/landmark_state.dart';

/// BLoC for managing Landmark feature state
class LandmarkBloc extends Bloc<LandmarkEvent, LandmarkState> {
  final ILandmarkRepository _repository;
  static const int _pageSize = 12;

  LandmarkBloc(this._repository) : super(const LandmarkState()) {
    on<LoadLandmarks>(_onLoadLandmarks);
    on<SearchLandmarks>(_onSearchLandmarks);
    on<LoadMoreLandmarks>(_onLoadMoreLandmarks);
    on<RefreshLandmarks>(_onRefreshLandmarks);
    on<CreateLandmark>(_onCreateLandmark);
    on<UpdateLandmark>(_onUpdateLandmark);
    on<DeleteLandmark>(_onDeleteLandmark);
    on<ClearLandmarkMessage>(_onClearMessage);
  }

  Future<void> _onLoadLandmarks(
    LoadLandmarks event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(state.copyWith(status: LandmarkLoadStatus.loading, clearError: true));

    try {
      final response = await _repository.getMalls(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        page: 1,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          status: LandmarkLoadStatus.loaded,
          malls: response.malls,
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.page < response.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LandmarkLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchLandmarks(
    SearchLandmarks event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(
      state.copyWith(
        searchQuery: event.query,
        status: LandmarkLoadStatus.loading,
        clearError: true,
      ),
    );

    try {
      final response = await _repository.getMalls(
        search: event.query.isEmpty ? null : event.query,
        page: 1,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          status: LandmarkLoadStatus.loaded,
          malls: response.malls,
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.page < response.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LandmarkLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreLandmarks(
    LoadMoreLandmarks event,
    Emitter<LandmarkState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getMalls(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        page: nextPage,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          isLoadingMore: false,
          malls: [...state.malls, ...response.malls],
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.page < response.totalPages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshLandmarks(
    RefreshLandmarks event,
    Emitter<LandmarkState> emit,
  ) async {
    try {
      final response = await _repository.getMalls(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        page: 1,
        limit: _pageSize,
      );

      emit(
        state.copyWith(
          status: LandmarkLoadStatus.loaded,
          malls: response.malls,
          currentPage: response.page,
          totalPages: response.totalPages,
          hasMore: response.page < response.totalPages,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateLandmark(
    CreateLandmark event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(
      state.copyWith(isCreating: true, clearError: true, clearSuccess: true),
    );

    try {
      await _repository.createMall(event.request, imagePath: event.imagePath);

      emit(
        state.copyWith(
          isCreating: false,
          successMessage: 'Landmark created successfully',
        ),
      );

      // Refresh the list
      add(const RefreshLandmarks());
    } catch (e) {
      emit(state.copyWith(isCreating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateLandmark(
    UpdateLandmark event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(
      state.copyWith(isUpdating: true, clearError: true, clearSuccess: true),
    );

    try {
      await _repository.updateMall(
        event.id,
        event.request,
        imagePath: event.imagePath,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          successMessage: 'Landmark updated successfully',
        ),
      );

      // Refresh the list
      add(const RefreshLandmarks());
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteLandmark(
    DeleteLandmark event,
    Emitter<LandmarkState> emit,
  ) async {
    emit(
      state.copyWith(isDeleting: true, clearError: true, clearSuccess: true),
    );

    try {
      await _repository.deleteMall(event.id);

      emit(
        state.copyWith(
          isDeleting: false,
          successMessage: 'Landmark deleted successfully',
        ),
      );

      // Refresh the list
      add(const RefreshLandmarks());
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: e.toString()));
    }
  }

  void _onClearMessage(
    ClearLandmarkMessage event,
    Emitter<LandmarkState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
