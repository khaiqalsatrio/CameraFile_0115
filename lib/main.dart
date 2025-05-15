import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pertemuan7_115/bloc/camera_bloc.dart';
import 'package:pertemuan7_115/presentation/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Ganti halaman utama di sini:
        home: const HomePage(),
        // atau jika ingin langsung ke FullPage:
        // home: const FullPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
