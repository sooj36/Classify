import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/scheduler.dart';

class TodoScreen extends StatelessWidget {
  final TodoViewModel todoViewModel;
  // bool isImportant = false;

  const TodoScreen({
    super.key,
    required this.todoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back, color: AppTheme.textColor1),
          //   onPressed: () => Navigator.of(context).pop(),
          // ), // 원복 예정
          title: const TabBar(
            indicatorColor: AppTheme.decorationColor1,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textColor2,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: AppTheme.primaryColor),
            ),
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Done'),
            ],
          ),
          backgroundColor: Colors.amber, // 임시
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                //검색 기능
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('검색 기능이 곧 추가될 예정입니다'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
              },
              icon: const Icon(Icons.search, color: AppTheme.textColor1),
            ),
          ],
        ),
        body: ValueListenableBuilder<Map<String, TodoModel>>(
          valueListenable: todoViewModel.toggleCheck,
          builder: (context, todoMap, child) {
            final todoList = todoMap.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return TabBarView(
              children: [
                // 미완료 탭
                _buildTabContent(
                    todoList.where((todo) => todo.isDone != true).toList(),
                    todoViewModel),

                // 완료 탭
                _buildTabContent(
                    todoList.where((todo) => todo.isDone == true).toList(),
                    todoViewModel),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context, todoViewModel),
          child: const Icon(Icons.add_box_outlined),
        ),
      ),
    );
  }
}

Widget _buildTabContent(List<TodoModel> filteredList, TodoViewModel viewModel) {
  return filteredList.isEmpty
      ? _buildEmptyState()
      : _buildTodoContent(filteredList, viewModel);
}

Widget _buildEmptyState() {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '할 일이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 할 일을 추가해주세요 💫',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildTodoContent(List<TodoModel> todoList, TodoViewModel viewModel) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(todoList.length),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: todoList.length,
            itemBuilder: (context, index) =>
                _buildTodoGridItem(context, todoList[index], viewModel),
          ),
        ),
      ],
    ),
  );
}

Widget _buildHeader(int count) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        // '${widget.viewModel.cachedTodoModels.length}개',
        '$count개',
        style: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: AppTheme.textColor2,
        ),
      ),
    ],
  );
}

Widget _buildTodoGridItem(
    BuildContext context, TodoModel todoObject, TodoViewModel viewModel) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(
        color: todoObject.isImportant == true
            ? AppTheme.errorColor
            : AppTheme.darkAccentColor,
        width: 1.5,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // todo 상세 보기 등 추가
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상세보기 기능이 곧 추가될 예정입니다.'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: todoObject.isDone ?? false,
                  onChanged: (newValue) {
                    // 디버그 로그 추가
                    debugPrint('===== 체크박스 클릭 =====');
                    debugPrint('todoId: ${todoObject.todoId}');
                    debugPrint('현재 상태: ${todoObject.isDone}');
                    debugPrint('새 상태: $newValue');

                    viewModel.toggleCompleted(todoObject.todoId);
                    // 간단한 상태 변경
                    TodoModel updatedTodo = todoObject.copyWith(
                      isDone: newValue, //
                      lastModified: DateTime.now(),
                    );
                    debugPrint('업데이트된 상태: ${updatedTodo.isDone}');

// 체크박스 onChanged 이벤트 핸들러 내부에서
                    viewModel.updateTodo(updatedTodo).then((_) {
                      // 다음 프레임에서 탭 전환 실행
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (newValue == true) {
                          DefaultTabController.of(context).animateTo(1);
                        } else {
                          DefaultTabController.of(context).animateTo(0);
                        }
                      });
                    });

                    debugPrint('===== 체크박스 처리 진행 중 =====');

                    // // 탭 전환을 약간 지연시켜 UI가 먼저 업데이트되도록 함
                    // Future.delayed(Duration(milliseconds: 100), () {
                    //   // 탭 전환
                    //   debugPrint('탭 전환 시작');
                    //   if (newValue == true) {
                    //     debugPrint('Done 탭으로 이동 시도 (인덱스 1)');
                    //     DefaultTabController.of(context)
                    //         .animateTo(1); // TO DONE
                    //   } else {
                    //     debugPrint('In Progress 탭으로 이동 시도 (인덱스 0)');
                    //     DefaultTabController.of(context)
                    //         .animateTo(0); // To In Progress
                    //   }
                    //   debugPrint('탭 전환 완료');
                    // });

                    debugPrint('===== 체크박스 처리 진행 중 =====');
                  },
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(context, todoObject, viewModel);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Expanded(
              child: Text(
                todoObject.todoContent,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: todoObject.isDone == true
                      ? TextDecoration.lineThrough
                      : null,
                  color: todoObject.isDone == true
                      ? const Color.fromARGB(255, 10, 16, 10)
                      : const Color.fromARGB(255, 7, 15, 14),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${todoObject.createdAt.year}.${todoObject.createdAt.month}.${todoObject.createdAt.day}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppTheme.textColor1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${todoObject.createdAt.hour.toString().padLeft(2, '0')}:${todoObject.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppTheme.textColor1,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _showDeleteConfirmation(
    BuildContext context, TodoModel todoObject, TodoViewModel viewModel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('할 일 삭제'),
      content: Text('\'${todoObject.todoContent}\' 항목을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            viewModel.deleteTodo(todoObject.todoId);
          },
          child: const Text('삭제', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

// 할일 추가 다이얼로그
void _showAddTodoDialog(BuildContext context, TodoViewModel todoViewModel) {
  final TextEditingController contentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Todo List 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Todo',
                hintText: '상세 내용을 입력하세요',
                hintStyle: TextStyle(color: Color.fromARGB(255, 97, 95, 95)),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            if (contentController.text.trim().isNotEmpty) {
              // ViewModel의 addTodo 메서드 호출

              todoViewModel.addTodo(contentController.text.trim());
              Navigator.pop(context);
            }
          },
          child:
              const Text('추가', style: TextStyle(color: AppTheme.primaryColor)),
        ),
      ],
    ),
  );
}
