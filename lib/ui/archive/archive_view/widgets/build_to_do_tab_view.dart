
// Widget buildTodoTabView(
//     Map<String, TodoModel> todos, TodoArchiveViewModel viewModel) {
//   // isDone 속성이 있는 메모만 필터링
//   final todoMemos = todos.values.where((todo) => todo.isDone != null).toList();

//   // 메모가 없는 경우 처리
//   if (todoMemos.isEmpty) {
//     return const Center(
//       child: Text(
//         "작성된 할 일이 없습니다",
//         style: TextStyle(
//           fontSize: 16,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }

//   // 최신순과 오래된순으로 정렬된 할일 리스트 생성
//   final latestTodos = List<TodoModel>.from(todoMemos)
//     ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

//   final oldestTodos = List<TodoModel>.from(todoMemos)
//     ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

//   // 현재 보여줄 할일 리스트 (기본값은 최신순)
//   ValueNotifier<List<TodoModel>> currentTodos =
//       ValueNotifier<List<TodoModel>>(latestTodos);

//   // 최신순인지 여부를 추적하는 플래그
//   ValueNotifier<bool> isLatestSort = ValueNotifier<bool>(true);

//   return Padding(
//     padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
//     child: Column(
//       children: [
//         // 정렬 버튼
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             _buildSortButton(
//                 isLatestSort: isLatestSort,
//                 isLatest: true,
//                 icon: Icons.arrow_downward,
//                 label: '최신순',
//                 onPressed: () {
//                   currentTodos.value = latestTodos;
//                   isLatestSort.value = true;
//                 }),
//             const SizedBox(width: 4),
//             _buildSortButton(
//                 isLatestSort: isLatestSort,
//                 isLatest: false,
//                 icon: Icons.arrow_upward,
//                 label: '오래된순',
//                 onPressed: () {
//                   currentTodos.value = oldestTodos;
//                   isLatestSort.value = false;
//                 }),
//           ],
//         ),
//         // 메모 리스트
//         Expanded(
//           child: ValueListenableBuilder<List<TodoModel>>(
//             valueListenable: currentTodos,
//             builder: (context, todosList, _) {
//               return ListView.builder(
//                 itemCount: todosList.length,
//                 itemBuilder: (context, index) => todoCards(
//                   context,
//                   todosList[index],
//                   onTaskCompleted: (todoId) {
//                     // 할 일이 어떤 카테고리에 있든 삭제
//                     final memo = todos[todoId];
//                     if (memo != null) {
//                       viewModel.deleteTodo(todoId);
//                     }
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSortButton({
//   required ValueNotifier<bool> isLatestSort,
//   required bool isLatest,
//   required IconData icon,
//   required String label,
//   required VoidCallback onPressed,
// }) {
//   return ValueListenableBuilder<bool>(
//       valueListenable: isLatestSort,
//       builder: (context, value, _) {
//         final bool isSelected = isLatest ? value : !value;
//         return TextButton.icon(
//           onPressed: onPressed,
//           icon: Icon(icon,
//               size: 16,
//               color: isSelected ? AppTheme.primaryColor : AppTheme.textColor1),
//           label: Text(label,
//               style: TextStyle(
//                   color: isSelected
//                       ? AppTheme.primaryColor
//                       : AppTheme.textColor1)),
//           style: TextButton.styleFrom(
//             backgroundColor: isSelected
//                 ? AppTheme.primaryColor.withOpacity(0.1)
//                 : Colors.transparent,
//           ),
//         );
//       });
// }

// Widget todoCards(BuildContext context, TodoModel todo,
//     {required Function(String) onTaskCompleted}) {
//   return Card(
//     margin: const EdgeInsets.only(bottom: 12.0),
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 체크박스
//           Transform.scale(
//             scale: 1.2,
//             child: Checkbox(
//               value: todo.isDone,
//               activeColor: AppTheme.primaryColor,
//               onChanged: (bool? value) {
//                 if (value == true) {
//                   // 체크했을 때 할일 완료 처리 - 삭제 수행
//                   onTaskCompleted(todo.todoId);
//                 }
//               },
//             ),
//           ),
//           const SizedBox(width: 12),
//           // 메모 내용
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   todo.todoContent,
//                   style: const TextStyle(fontSize: 14),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
