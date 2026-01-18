import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick an image from camera
  Future<File?> pickImageFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  /// Show dialog to choose between camera and gallery
  Future<File?> pickImage({
    required bool Function() showCameraOption,
    required Future<File?> Function() onGallery,
    required Future<File?> Function() onCamera,
  }) async {
    final bool showCamera = showCameraOption();

    if (showCamera) {
      // Show dialog to choose between camera and gallery
      // This should be implemented in the UI layer
      throw UnimplementedError(
        'Use pickImageFromGallery or pickImageFromCamera directly',
      );
    } else {
      return await onGallery();
    }
  }
}
