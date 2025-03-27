import 'package:flutter/material.dart';
import 'dart:io';
import '../view_models/cloth_add_viewmodel.dart';
import 'package:go_router/go_router.dart';

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
            : ListView(
                children: [
                  cameraButtonArea(),
                  if (widget.viewModel.cloth?.file != null)
                    imageArea(),
                  if (widget.viewModel.cloth?.response != null)
                    responseArea(),
                  if (widget.viewModel.cloth?.response != null)
                    saveButtonArea(),
                  if (widget.viewModel.error != null)
                    errorArea(),
                ],
              ),
        );
      },
    );
  }

  Row cameraButtonArea() {
    return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 185, 206, 223),
                      ),
                      onPressed: widget.viewModel.takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('카메라', style: TextStyle(color: Colors.black),),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: widget.viewModel.pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('갤러리', style: TextStyle(color: Colors.black),),
                    ),
                  ],
                );
  }

  Widget imageArea() {
    // 가상 피팅 이미지가 있으면 먼저 보여줌
    if (widget.viewModel.cloth?.imageUrl != null && widget.viewModel.cloth!.imageUrl!.isNotEmpty) {
      return Column(
        children: [
          Image.network(
            widget.viewModel.cloth!.imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null 
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('이미지 로딩 실패', style: TextStyle(color: Colors.red)),
              );
            },
          ),
          const SizedBox(height: 10),
          const Text('가상 피팅 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // 원본 이미지
          Image.file(
            File(widget.viewModel.cloth!.file!.path),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text('원본 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }
    
    // 원본 이미지만 표시
    return Image.file(
      File(widget.viewModel.cloth!.file!.path),
      fit: BoxFit.contain,
    );
  }

  Text responseArea() {
    return Text(
      widget.viewModel.cloth!.response!,
      style: const TextStyle(color: Colors.blue),
    );
  }

  ElevatedButton saveButtonArea() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      onPressed: () {
        widget.viewModel.saveCloth();
        context.pop();
      },
      child: const Text('저장'),
    );
  }

  Text errorArea() {
    return Text(
      widget.viewModel.error!,
      style: const TextStyle(color: Colors.red),
    );
  }
} 