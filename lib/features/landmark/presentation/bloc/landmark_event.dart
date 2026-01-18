import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/landmark/data/models/mall_model.dart';

/// Base class for all Landmark events
abstract class LandmarkEvent extends Equatable {
  const LandmarkEvent();

  @override
  List<Object?> get props => [];
}

/// Load malls list
class LoadLandmarks extends LandmarkEvent {
  const LoadLandmarks();
}

/// Search malls
class SearchLandmarks extends LandmarkEvent {
  final String query;

  const SearchLandmarks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Load more malls (pagination)
class LoadMoreLandmarks extends LandmarkEvent {
  const LoadMoreLandmarks();
}

/// Refresh malls list
class RefreshLandmarks extends LandmarkEvent {
  const RefreshLandmarks();
}

/// Create a new mall
class CreateLandmark extends LandmarkEvent {
  final CreateMallRequest request;
  final String? imagePath;

  const CreateLandmark({required this.request, this.imagePath});

  @override
  List<Object?> get props => [request, imagePath];
}

/// Update existing mall
class UpdateLandmark extends LandmarkEvent {
  final String id;
  final UpdateMallRequest request;
  final String? imagePath;

  const UpdateLandmark({
    required this.id,
    required this.request,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, request, imagePath];
}

/// Delete a mall
class DeleteLandmark extends LandmarkEvent {
  final String id;

  const DeleteLandmark(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clear any action messages (success/error)
class ClearLandmarkMessage extends LandmarkEvent {
  const ClearLandmarkMessage();
}
