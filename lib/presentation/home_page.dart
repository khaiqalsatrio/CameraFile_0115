import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pertemuan7_115/bloc/camera_bloc.dart';
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
            if (state is CameraReady && state.snackbarMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackbarMessage!)));
              context.read<CameraBloc>().add(ClearSnackbar());
            }
          },