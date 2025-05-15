import 'dart:io';
import 'package:camera/camera.dart';

sealed class CameraState {}

final class CameraInitial extends CameraState {}

final class Cameraready extends CameraState {
  final CameraController controller;
  final int selectedIndex;
  final FlashMode flashMode;
  final File? imageFile;
  final String? snackBarMessage;

  Cameraready({
    required this.controller,
    required this.selectedIndex,
    required this.flashMode,
    this.imageFile,
    this.snackBarMessage,
  });

  Cameraready copyWith({
    CameraController? controller,
    int? selectedIndex,
    FlashMode? flashMode,
    File? imageFile,
    String? snackBarMessage,
    bool clearSnackbar = false,
  }) {
    return Cameraready(
      controller: controller ?? this.controller,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      flashMode: flashMode ?? this.flashMode,
      imageFile: imageFile ?? this.imageFile,
      snackBarMessage:
          clearSnackbar ? null : snackBarMessage ?? this.snackBarMessage,
    );
  }
}
