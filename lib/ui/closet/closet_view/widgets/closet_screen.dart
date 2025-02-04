import 'package:flutter/material.dart';
import '../../../../routing/router.dart';
import '../../../../routing/routes.dart';
import '../view_models/closet_view_model.dart';

// class ClosetScreen extends StatefulWidget {


class ClosetScreen extends StatefulWidget {
  final ClosetViewModel viewModel;
  const ClosetScreen({super.key, required this.viewModel});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchClothes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List>(
        stream: widget.viewModel.clothes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('옷장이 비어있습니다'));
          }

          final clothes = snapshot.data!;
          // major 값들의 중복을 제거하여 유니크한 리스트 생성
          final uniqueMajors = clothes.map((c) => c.major).toSet().toList();
          
          return DefaultTabController(
            length: uniqueMajors.length,  // 유니크한 major 개수로 변경
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  tabs: uniqueMajors.map((major) => 
                    Tab(text: major ?? 'Unknown')
                  ).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: uniqueMajors.map((major) {
                      final majorClothes = clothes.where((c) => c.major == major).toList();
                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,  // 한 줄에 2개의 아이템
                          crossAxisSpacing: 16,  // 가로 간격
                          mainAxisSpacing: 16,  // 세로 간격
                          childAspectRatio: 0.75,  // 가로:세로 비율
                        ),
                        itemCount: majorClothes.length,
                        itemBuilder: (context, index) {
                          final cloth = majorClothes[index];
                          return individualCards(cloth);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        onPressed: () {
          router.push(Routes.clothAdd);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Card individualCards(cloth) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _buildClothImage(cloth),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    cloth.minor ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothImage(cloth) {
    return cloth.imagePath != null
      ? Image.network(
          cloth.imagePath!,
          fit: BoxFit.cover,
        )
      : Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 40),
        );
  }
}











