import 'package:flutter/material.dart';
import 'dart:io';
import '../view_models/cloth_add_viewmodel.dart';

class ClothAddScreen extends StatefulWidget {
  final ClothAddViewModel viewModel;

  const ClothAddScreen({super.key, required this.viewModel});

  @override
  State<ClothAddScreen> createState() => _ClothAddScreenState();
}

class _ClothAddScreenState extends State<ClothAddScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('옷 추가')),
          body: widget.viewModel.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.viewModel.cloth?.imagePath != null)  
                    imageArea(),
                  if (widget.viewModel.cloth?.response != null)
                    responseArea(),
                  buttonArea(),
                  if (widget.viewModel.error != null)
                    errorArea(),
                ],
              ),
        );
      },
    );
  }

  Row buttonArea() {
    return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.viewModel.takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('카메라'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.viewModel.pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('갤러리'),
                    ),
                  ],
                );
  }

  Expanded imageArea() {
    return Expanded(
                    child: Image.file(
                      File(widget.viewModel.cloth!.imagePath),
                      fit: BoxFit.contain,
                    ),
                  );
  }

  Text responseArea() {
    return Text(
      widget.viewModel.cloth!.response!,
      style: const TextStyle(color: Colors.blue),
    );
  }

  Text errorArea() {
    return Text(
      widget.viewModel.error!,
      style: const TextStyle(color: Colors.red),
    );
  }
} 