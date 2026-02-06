import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/feedback_repository_interface.dart';
import '../../data/models/feedback_model.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepositoryInterface repository;
  static const int pageSize = 5;

  FeedbackBloc({required this.repository}) : super(FeedbackState.initial()) {
    on<LoadFeedbacks>(_onLoadFeedbacks);
    on<ChangeFilter>(_onChangeFilter);
    on<LoadNextPage>(_onLoadNextPage);
    on<LoadPreviousPage>(_onLoadPreviousPage);
    on<GoToPage>(_onGoToPage);
    on<ReplyToFeedback>(_onReplyToFeedback);
    on<RefreshFeedbacks>(_onRefreshFeedbacks);
  }

  Future<void> _onLoadFeedbacks(
    LoadFeedbacks event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, isLoadingStats: true, clearError: true),
    );

    try {
      // Load stats and feedbacks in parallel
      final results = await Future.wait([
        repository.getStats(),
        repository.getFeedbacks(
          filter: state.filter,
          page: state.currentPage,
          limit: pageSize,
        ),
        repository.getTotalCount(state.filter),
      ]);

      final stats = results[0] as FeedbackStats;
      final feedbacks = results[1] as List<FeedbackModel>;
      final totalCount = results[2] as int;
      final totalPages = (totalCount / pageSize).ceil();

      emit(
        state.copyWith(
          feedbacks: feedbacks,
          stats: stats,
          totalCount: totalCount,
          totalPages: totalPages > 0 ? totalPages : 1,
          isLoading: false,
          isLoadingStats: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingStats: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeFilter(
    ChangeFilter event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter, currentPage: 1, isLoading: true));

    try {
      final results = await Future.wait([
        repository.getFeedbacks(filter: event.filter, page: 1, limit: pageSize),
        repository.getTotalCount(event.filter),
      ]);

      final feedbacks = results[0] as List<FeedbackModel>;
      final totalCount = results[1] as int;
      final totalPages = (totalCount / pageSize).ceil();

      emit(
        state.copyWith(
          feedbacks: feedbacks,
          totalCount: totalCount,
          totalPages: totalPages > 0 ? totalPages : 1,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<FeedbackState> emit,
  ) async {
    if (!state.hasNextPage) return;
    add(GoToPage(state.currentPage + 1));
  }

  Future<void> _onLoadPreviousPage(
    LoadPreviousPage event,
    Emitter<FeedbackState> emit,
  ) async {
    if (!state.hasPreviousPage) return;
    add(GoToPage(state.currentPage - 1));
  }

  Future<void> _onGoToPage(GoToPage event, Emitter<FeedbackState> emit) async {
    if (event.page < 1 || event.page > state.totalPages) return;

    emit(state.copyWith(currentPage: event.page, isLoading: true));

    try {
      final feedbacks = await repository.getFeedbacks(
        filter: state.filter,
        page: event.page,
        limit: pageSize,
      );

      emit(state.copyWith(feedbacks: feedbacks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onReplyToFeedback(
    ReplyToFeedback event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(replyingToId: event.feedbackId));

    try {
      final updatedFeedback = await repository.replyToFeedback(
        event.feedbackId,
        event.reply,
      );

      // Update the feedback in the list
      final updatedList = state.feedbacks.map((f) {
        if (f.id == event.feedbackId) return updatedFeedback;
        return f;
      }).toList();

      emit(state.copyWith(feedbacks: updatedList, clearReplyingId: true));
    } catch (e) {
      emit(state.copyWith(clearReplyingId: true, error: e.toString()));
    }
  }

  Future<void> _onRefreshFeedbacks(
    RefreshFeedbacks event,
    Emitter<FeedbackState> emit,
  ) async {
    add(LoadFeedbacks());
  }
}
