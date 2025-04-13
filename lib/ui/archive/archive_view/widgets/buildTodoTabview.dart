import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/ui/archive/archive_view/view_models/archive_view_model.dart';

Widget buildTodoTabView(Map<String, MemoModel> memos, ArchiveViewModel viewModel) {
  // '할 일' 카테고리만 필터링
  final todoMemos = memos.values
      .where((memo) => memo.category == '할 일')
      .toList();
  
  // 최신순과 오래된순으로 정렬된 메모 리스트 생성
  final latestMemos = List<MemoModel>.from(todoMemos)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  final oldestMemos = List<MemoModel>.from(todoMemos)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  
  // 현재 보여줄 메모 리스트 (기본값은 최신순)
  ValueNotifier<List<MemoModel>> currentMemos = ValueNotifier<List<MemoModel>>(latestMemos);
  
  // 최신순인지 여부를 추적하는 플래그
  ValueNotifier<bool> isLatestSort = ValueNotifier<bool>(true);

  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
    child: Column(
      children: [
        // 정렬 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildSortButton(
              isLatestSort: isLatestSort, 
              isLatest: true, 
              icon: Icons.arrow_downward, 
              label: '최신순', 
              onPressed: () {
                currentMemos.value = latestMemos;
                isLatestSort.value = true;
              }
            ),
            const SizedBox(width: 4),
            _buildSortButton(
              isLatestSort: isLatestSort, 
              isLatest: false, 
              icon: Icons.arrow_upward, 
              label: '오래된순', 
              onPressed: () {
                currentMemos.value = oldestMemos;
                isLatestSort.value = false;
              }
            ),
          ],
        ),
        // 메모 리스트
        Expanded(
          child: ValueListenableBuilder<List<MemoModel>>(
            valueListenable: currentMemos,
            builder: (context, memosList, _) {
              return ListView.builder(
                itemCount: memosList.length,
                itemBuilder: (context, index) => todoCards(
                  context,
                  memosList[index],
                  onTaskCompleted: (memoId) {
                    viewModel.deleteMemo(memoId);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildSortButton({
  required ValueNotifier<bool> isLatestSort,
  required bool isLatest,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return ValueListenableBuilder<bool>(
    valueListenable: isLatestSort,
    builder: (context, value, _) {
      final bool isSelected = isLatest ? value : !value;
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: isSelected ? Colors.blue : Colors.black),
        label: Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
      );
    }
  );
}

Widget todoCards(BuildContext context, MemoModel memo, {required Function(String) onTaskCompleted}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크박스
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: memo.isDone,
              activeColor: Colors.green,
              onChanged: (bool? value) {
                if (value == true) {
                  // 체크했을 때 할일 완료 처리 - 삭제 수행
                  onTaskCompleted(memo.memoId);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // 메모 내용
          Expanded(
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
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
