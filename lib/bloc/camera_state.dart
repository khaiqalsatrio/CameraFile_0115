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
}
