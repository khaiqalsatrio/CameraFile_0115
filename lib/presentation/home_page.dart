import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pertemuan7_115/bloc/camera_bloc.dart';
import 'package:pertemuan7_115/bloc/camera_event.dart';
import 'package:pertemuan7_115/bloc/camera_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: SafeArea(
        child: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (state is Cameraready && state.snackBarMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackBarMessage!)));
              context.read<CameraBloc>().add(ClearSnackbar());
            }
          },
          builder: (context, state) {
            // final File? imageFile =
            //    State is CameraReady ? state.imageFile : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera),
                        label: const Text('Ambil Foto'),
                        onPressed: () {
                          final bloc = context.read<CameraBloc>();
                          if (bloc.state is! Cameraready) {
                            bloc.add(InitializeCamera());
                          }
                          bloc.add(OpenCameraAndCapture(context));
                        },
                      ),
                    ),