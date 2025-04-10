import 'package:flutter/material.dart';
import 'package:weathercloset/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:weathercloset/domain/models/memo/memo_model.dart';

class ArchiveScreen extends StatefulWidget {
  final ArchiveViewModel viewModel;
  const ArchiveScreen({super.key, required this.viewModel});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    //archiveScreen이 완전히 그려진 후에 fetchMemo를 안전하게 실행하기 위함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchMemos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.error != null) {
            return Center(child: Text('에러 발생: ${widget.viewModel.error}'));
          }
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.cachedMemos.isEmpty) {
            return const Center(child: Text('메모장이 비어있습니다'));
          }

          // 데이터 형식 변환
          final memos = widget.viewModel.cachedMemos;
          // clothmodel의 major 값들의 중복을 제거하여 유니크한 리스트 생성
          final uniqueCategories = memos.values.map((c) => c.category).toSet().toList();
          
          return DefaultTabController(
            length: uniqueCategories.length,  // 유니크한 major 개수로 변경
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  tabs: uniqueCategories.map((category) => 
                    Tab(text: category ?? 'Unknown')
                  ).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: uniqueCategories.map((category) {
                      final categories = memos.values.where((c) => c.category == category).toList();
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final memo = categories[index];
                          return individualCards(memo);
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
    );
  }

  Card individualCards(MemoModel memo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('삭제 확인'),
              content: const Text('정말로 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                memo.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    memo.category,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (memo.isImportant)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}











