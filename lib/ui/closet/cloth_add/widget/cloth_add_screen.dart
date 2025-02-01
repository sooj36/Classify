import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../view_models/cloth_add_viewmodel.dart';
import '../../../../repositories/cloth_repository.dart';

class ClothAddScreen extends StatelessWidget {
  const ClothAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClothAddViewModel(ClothRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('옷 추가하기')),
        body: Consumer<ClothAddViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }           
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (viewModel.cloth?.imagePath != null)
                  Expanded(
                    child: Image.file(
                      File(viewModel.cloth!.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: viewModel.takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('카메라'),
                    ),
                    ElevatedButton.icon(
                      onPressed: viewModel.pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('갤러리'),
                    ),
                  ],
                ),
                if (viewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
} 