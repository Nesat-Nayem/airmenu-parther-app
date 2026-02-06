import 'package:equatable/equatable.dart';
import '../../../data/models/admin/restaurant_creation_models.dart';

enum SubmissionStatus { initial, loading, success, failure }

class CreateRestaurantState extends Equatable {
  final List<PlaceAutocompleteModel> suggestions;
  final bool isAutocompleteLoading;
  final SubmissionStatus submissionStatus;
  final String? error;
  final String? successMessage;

  const CreateRestaurantState({
    this.suggestions = const [],
    this.isAutocompleteLoading = false,
    this.submissionStatus = SubmissionStatus.initial,
    this.error,
    this.successMessage,
  });

  CreateRestaurantState copyWith({
    List<PlaceAutocompleteModel>? suggestions,
    bool? isAutocompleteLoading,
    SubmissionStatus? submissionStatus,
    String? Function()? error,
    String? Function()? successMessage,
  }) {
    return CreateRestaurantState(
      suggestions: suggestions ?? this.suggestions,
      isAutocompleteLoading:
          isAutocompleteLoading ?? this.isAutocompleteLoading,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error != null ? error() : this.error,
      successMessage: successMessage != null
          ? successMessage()
          : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    suggestions,
    isAutocompleteLoading,
    submissionStatus,
    error,
    successMessage,
  ];
}
