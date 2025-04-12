import 'package:weathercloset/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/ui/archive/archive_view/view_models/archive_view_model.dart';
Widget buildTodoTabView(Map<String, MemoModel> memos, ArchiveViewModel viewModel) {
  // '할 일' 카테고리만 필터링
  final todoMemos = memos.values
      .where((memo) => memo.category == '할 일')
      .toList();
  
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView.builder(
      itemCount: todoMemos.length,
      itemBuilder: (context, index) => todoCards(
        context,
        todoMemos[index],
        onTaskCompleted: (memoId) { //todoCards는 할 일 표시에만 집중하게 하기 위함
          // 여기서 메모 삭제 로직 구현 (ViewModel을 통해)
          // 실제 구현에서는 위젯에서 ViewModel의 메서드를 호출해야 합니다
          viewModel.deleteMemo(memoId);
        },
      ),
    ),
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
                    if (memo.isImportant == true)
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
