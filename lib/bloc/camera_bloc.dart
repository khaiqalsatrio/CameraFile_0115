import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pertemuan7_115/bloc/camera_event.dart';
import 'package:pertemuan7_115/bloc/camera_state.dart';
import 'package:pertemuan7_115/camera_page.dart';
import 'package:pertemuan7_115/storage_helper.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  late final List<CameraDescription> _cameras;

  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInit);
    on<SwitchCamera>(_onSwitch);
    on<ToogleFlash>(_onToggleFlash);
    on<TakePicture>(_onTakePicture);
    on<TapToFocus>(_onTapFocus);
    on<PickImageFromGallery>(_onPickGallery);
    on<OpenCameraAndCapture>(_onOpenCamera);
    on<DeleteImage>(_onDeleteImage);
    on<ClearSnackbar>(_onClearSnackbar);
    on<RequestPermission>(_onRequestPermissions);
  }
  Future<void> _onInit(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    _cameras = await availableCameras();

    await _setupController(0, emit);
  }

  Future<void> _onSwitch(SwitchCamera event, Emitter<CameraState> emit) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    final next = (s.selectedIndex + 1) % _cameras.length;
    await _setupController(next, emit, previous: s);
  }

  Future<void> _onToggleFlash(
    ToogleFlash event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    final next =
        s.flashMode == FlashMode.off
            ? FlashMode.auto
            : s.flashMode == FlashMode.auto
            ? FlashMode.always
            : FlashMode.off;
    await s.controller.setFlashMode(next);
    emit(s.copyWith(flashMode: next));
  }

  Future<void> _onTakePicture(
    TakePicture event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    final file = await s.controller.takePicture();
    event.onPictureTaken(File(file.path));
  }

  Future<void> _onTapFocus(TapToFocus event, Emitter<CameraState> emit) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    final relative = Offset(
      event.position.dx / event.previewSize.width,
      event.position.dy / event.previewSize.height,
    );
    await s.controller.setFocusPoint(relative);
    await s.controller.setExposurePoint(relative);
  }

  Future<void> _onPickGallery(
    PickImageFromGallery event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! Cameraready) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    final file = File(picked!.path);
    emit(
      (state as Cameraready).copyWith(
        imageFile: file,
        snackBarMessage: 'Berhasil memilih dari galeri',
      ),
    );
  }

  Future<void> _onOpenCamera(
    OpenCameraAndCapture event,
    Emitter<CameraState> emit,
  ) async {
    print('[CameraBloc] OpenCameraAndCapture triggered');

    if (state is! Cameraready) {
      print('[CameraBloc] state is not ready, abort');
      return;
    }

    final file = await Navigator.push<File?>(
      event.context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(value: this, child: const CameraPage()),
      ),
    );

    if (file != null) {
      final saved = await StorageHelper.saveImage(file, 'camera');
      emit(
        (state as Cameraready).copyWith(
          imageFile: saved,
          snackBarMessage: 'Disimpan ${saved.path}',
        ),
      );
    }
  }

  Future<void> _onDeleteImage(
    DeleteImage event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    await s.imageFile?.delete();
    emit(
      Cameraready(
        controller: s.controller,
        selectedIndex: s.selectedIndex,
        flashMode: s.flashMode,
        imageFile: null,
        snackBarMessage: 'Gambar dihapus',
      ),
    );
  }

  Future<void> _onClearSnackbar(
    ClearSnackbar event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! Cameraready) return;
    final s = state as Cameraready;
    emit(s.copyWith(clearSnackbar: true));
  }

  Future<void> _setupController(
    int index,
    Emitter<CameraState> emit, {
    Cameraready? previous,
  }) async {
    await previous?.controller.dispose();
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller.initialize();
    await controller.setFlashMode(previous?.flashMode ?? FlashMode.off);

    emit(
      Cameraready(
        controller: controller,
        selectedIndex: index,
        flashMode: previous?.flashMode ?? FlashMode.off,
        imageFile: previous?.imageFile,
        snackBarMessage: null,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (state is Cameraready) {
      await (state as Cameraready).controller.dispose();
    }
    return super.close();
  }

  Future<void> _onRequestPermissions(
    RequestPermission event,
    Emitter<CameraState> emit,
  ) async {
    final statuses =
        await [
          Permission.camera,
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

    final denied = statuses.entries.where((e) => !e.value.isGranted).toList();

    if (denied.isNotEmpty) {
      if (state is Cameraready) {
        emit(
          (state as Cameraready).copyWith(
            snackBarMessage: 'Izin Kamera atau penyimpanan ditolak,',
          ),
        );
      }
    }
  }
}
