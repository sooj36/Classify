import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../domain/models/cloth/cloth_model.dart';
import '../view_model/self_fitting_room_view_model.dart';

class SelfFittingRoomScreen extends StatefulWidget {
  final SelfFittingRoomViewModel viewModel;
  
  const SelfFittingRoomScreen({
    Key? key, 
    required this.viewModel,
  }) : super(key: key);

  @override
  State<SelfFittingRoomScreen> createState() => _SelfFittingRoomScreenState();
}

class _SelfFittingRoomScreenState extends State<SelfFittingRoomScreen> {
  // 선택된 옷 ID 목록을 저장하는 Set (순서 유지를 위해 LinkedHashSet 사용 가능)
  final Set<String> selectedClothIds = {};
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchClothes();
  });
  }

  @override
  Widget build(BuildContext context) {
    final cachedClothes = widget.viewModel.cachedClothes;
    final isLoading = widget.viewModel.isLoading;
    final error = widget.viewModel.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('가상 피팅룸'),
        centerTitle: true,
        actions: [
          // 선택된 옷 초기화 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                selectedClothIds.clear();
              });
            },
            tooltip: '초기화',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('오류 발생: $error'))
              : Column(
                  children: [
                    // 메인 피팅 영역 (Stack)
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 기본 모델 이미지 (맨 아래)
                              Image.asset(
                                'assets/woman_model.jpg',
                                fit: BoxFit.contain,
                              ),
                              
                              // 선택된 모든 옷 이미지를 스택에 추가
                              ...selectedClothIds
                                  .where((id) => cachedClothes.containsKey(id))
                                  .map((id) => _buildClothLayer(cachedClothes[id]!)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 옷 선택 영역 (가로 스크롤 리스트뷰)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '내 옷장',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  // 현재 선택된 옷 개수 표시
                                  Text(
                                    '선택: ${selectedClothIds.length}개',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: cachedClothes.isEmpty
                                  ? const Center(child: Text('등록된 옷이 없습니다.'))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: cachedClothes.length,
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      itemBuilder: (context, index) {
                                        final clothId = cachedClothes.keys.elementAt(index);
                                        final cloth = cachedClothes[clothId]!;
                                        
                                        return _buildClothItem(cloth, clothId);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildClothItem(ClothModel cloth, String clothId) {
    final isSelected = selectedClothIds.contains(clothId);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // 이미 선택된 옷이면 선택 해제, 아니면 선택 추가
          if (isSelected) {
            selectedClothIds.remove(clothId);
          } else {
            // 옷 카테고리가 같은 경우 기존 선택을 제거하고 새 선택을 추가하는 로직 (옵션)
            // 같은 종류의 옷(상의, 하의 등)은 하나만 선택 가능하게 할 경우 사용
            /*
            if (cloth.major != null) {
              selectedClothIds.removeWhere((id) => 
                cachedClothes.containsKey(id) && 
                cachedClothes[id]!.major == cloth.major
              );
            }
            */
            selectedClothIds.add(clothId);
          }
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 3.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11.0),
                  topRight: Radius.circular(11.0),
                ),
                child: _buildClothItemImage(cloth),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                cloth.minor ?? cloth.major ?? '의류',
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothItemImage(ClothModel cloth) {
    // 이미지 우선순위: 로컬 이미지 경로 -> 기본 이미지
    if (cloth.localImagePath != null) {
      return Image.file(
        File(cloth.localImagePath!),
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildClothLayer(ClothModel cloth) {
    // 피팅룸에 표시할 이미지 레이어
    if (cloth.localImagePath != null) {
      return Image.file(
        File(cloth.localImagePath!),
        fit: BoxFit.contain,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}