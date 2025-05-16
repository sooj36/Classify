import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';

enum ImportancePriority { veryImportant, important, none }

class TodoScreen extends StatefulWidget {
  final TodoViewModel todoViewModel;

  const TodoScreen({super.key, required this.todoViewModel});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoModel> latestTodos = [];
  List<TodoModel> oldestTodos = [];
  bool isLatestSort = true;

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.todoViewModel.initCachedTodos();
      widget.todoViewModel.connectStreamToCachedTodos();
      widget.todoViewModel.startAutoCleanup();
    });
    // 리스너 추가
    widget.todoViewModel.addListener(_todoListener);
  }

  void _todoListener() {
    if (mounted) {
      // _sortTodos();
      setState(() {});
    }
  }

  // void _sortTodos() {
  //   if (widget.todoViewModel.cachedTodos.isNotEmpty) {
  //     latestTodos =
  //         List<TodoModel>.from(widget.todoViewModel.cachedTodos.values)
  //           ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //     oldestTodos =
  //         List<TodoModel>.from(widget.todoViewModel.cachedTodos.values)
  //           ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //   }
  // }

  List<TodoModel> _sortInProgressTodos(
      List<TodoModel> todoList, bool isLatestSort) {
    final sortedList = List<TodoModel>.from(todoList);
    sortedList.sort((a, b) => isLatestSort
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return sortedList;
  }

// 완료된 할 일 정렬 (완료 날짜 기준)
  List<TodoModel> _sortDoneTodos(List<TodoModel> todoList, bool isLatestSort) {
    final sortedList = List<TodoModel>.from(todoList);
    sortedList.sort((a, b) {
      // lastModified가 완료 시간을 나타냄
      final aTime = a.lastModified ?? a.createdAt;
      final bTime = b.lastModified ?? b.createdAt;
      return isLatestSort
          ? bTime.compareTo(aTime) // 최신순
          : aTime.compareTo(bTime); // 오래된순
    });
    return sortedList;
  }

  void _showAddTodoDialog() {
    final TextEditingController todoController = TextEditingController();
    ImportancePriority? selectedImportance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                '계획 한 줄, 성취 한 걸음',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                        hintText: '할 일을 입력하세요',
                        hintStyle: const TextStyle(
                          color: AppTheme.textColor2,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppTheme.decorationColor1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      autofocus: true,
                      maxLines: 3, // 여러 줄 입력 가능하도록 설정
                      minLines: 3, // 최소 3줄 높이 유지
                      textInputAction: TextInputAction.newline, // 엔터키 동작 설정
                    ),
                    const SizedBox(height: 16),

                    // 중요도 선택
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 일반 옵션
                              _buildImportanceOption(
                                context,
                                isSelected: selectedImportance == null,
                                onTap: () =>
                                    setState(() => selectedImportance = null),
                                icon: Icons.circle_outlined,
                                color: Colors.grey,
                                label: '일반',
                              ),

                              // 중요 옵션
                              _buildImportanceOption(
                                context,
                                isSelected: selectedImportance ==
                                    ImportancePriority.important,
                                onTap: () => setState(() => selectedImportance =
                                    ImportancePriority.important),
                                icon: Icons.label_important_outline,
                                color: AppTheme.importantColor,
                                label: '중요',
                              ),

                              // 매우 중요 옵션
                              _buildImportanceOption(
                                context,
                                isSelected: selectedImportance ==
                                    ImportancePriority.veryImportant,
                                onTap: () => setState(() => selectedImportance =
                                    ImportancePriority.veryImportant),
                                icon: Icons.priority_high,
                                color: AppTheme.errorColor,
                                label: '매우 중요',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (todoController.text.trim().isNotEmpty) {
                      // 중요도 설정
                      bool isVeryImportant = selectedImportance ==
                          ImportancePriority.veryImportant;

                      bool isImportant =
                          selectedImportance == ImportancePriority.important;

                      //
                      widget.todoViewModel.createTodo(
                        todoController.text,
                        isImportant: isImportant,
                        isVeryImportant: isVeryImportant,
                      );
                      Navigator.pop(context);
                      setState(() {
                        // _sortTodos();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('추가'),
                ),
              ],
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
            );
          },
        );
      },
    );
  }

  void _showEditTodoDialog(TodoModel todo) {
    final TextEditingController todoController =
        TextEditingController(text: todo.todoContent);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: TextField(
              controller: todoController,
              decoration: const InputDecoration(hintText: '할 일을 채워주세요'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (todoController.text.trim().isNotEmpty) {
                    // 수정된 Todo 모델 생성
                    final updatedTodo = todo.copyWith(
                      todoContent: todoController.text,
                      lastModified: DateTime.now(),
                    );
                    // ViewModel을 통해 업데이트
                    widget.todoViewModel.updateTodo(updatedTodo);
                    Navigator.pop(context);
                    setState(() {
                      // _sortInProgressTodos(todoList?, isLatestSort)
                    });
                  }
                },
                child: const Text('수정'),
              ),
            ],
          );
        });
  }

  Widget _buildTodoList(List<TodoModel> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Image.asset(
                      'assets/bad_logo_icon.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "빈 캔버스와 같은 이 공간,\n당신의 성취로 채워보세요",
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textColor2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) =>
          todoCards(context, todos[index], onTaskCompleted: (todoId) {
        widget.todoViewModel.toggleTodoStatus(todoId);
        setState(() {});
      }),
    );
  }

  Widget todoCards(BuildContext context, TodoModel todo,
      {required Function(String) onTaskCompleted}) {
    final bool isDone = todo.isDone ?? false;
    final bool isImportant = todo.isImportant ?? false;
    final bool isVeryImportant = todo.isveryImportant ?? false;

    return InkWell(
      onTap: () {
        _showEditTodoDialog(todo);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            // 중요도 + 체크박스
            Positioned(
              top: 8,
              left: 8,
              bottom: 0,
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisSize.min,
                  children: [
                    if (isVeryImportant)
                      Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.errorColor,
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            color: AppTheme.textColor1,
                            size: 7,
                          ),
                        ),
                      )
                    else if (isImportant)
                      Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.importantColor,
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.label_important_outline,
                            color: AppTheme.textColor1,
                            size: 7,
                          ),
                        ),
                      ),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: todo.isDone,
                        onChanged: (bool? value) {
                          widget.todoViewModel.toggleTodoStatus(todo.todoId);
                          // 완료 처리 시 안내 메시지 표시
                          if (value == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('완료된 할 일은 24시간 뒤 자동삭제 됩니다'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.decorationColor2,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 할 일 내용
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
              child: Center(
                child: Text(
                  todo.todoContent,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.grey,
                    decorationThickness: 2.0,
                    color: isDone ? Colors.grey : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
            ),

            // 시간
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                _formatDateTime(todo.lastModified ?? todo.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // 시간
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Text(
            //       _formatDateTime(todo.lastModified ?? todo.createdAt),
            //       style: TextStyle(
            //         fontSize: 10,
            //         color: Colors.grey[600],
            //         fontStyle: FontStyle.italic,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportanceOption(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.maybeOf(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox.shrink(), // 뒤로가기 버튼 제거
          actions: [
            // 정렬 버튼 추가
            IconButton(
              onPressed: () {
                setState(() {
                  isLatestSort = !isLatestSort;
                });
              },
              icon: Icon(
                isLatestSort ? Icons.arrow_upward : Icons.arrow_downward,
                color: AppTheme.additionalColor,
              ),
              tooltip: tabController?.index == 0
                  ? (isLatestSort ? '최신 작성순' : '오래된 작성순')
                  : (isLatestSort ? '최근 완료순' : '오래전 완료순'),
            ),
          ],
          toolbarHeight: 40, // 높이
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15), // 하단 모서리만 둥글게
            ),
          ),
          backgroundColor: AppTheme.backgroundColor,
          bottom: const TabBar(
            indicatorColor: AppTheme.secondaryColor1,
            indicatorWeight: 3,
            labelColor: AppTheme.secondaryColor2,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions_outlined),
                    SizedBox(width: 8),
                    Text(
                      'IN PROGRESS',
                      style: TextStyle(color: AppTheme.additionalColor),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt_outlined),
                    SizedBox(width: 8),
                    Text(
                      'DONE',
                      style: TextStyle(color: AppTheme.additionalColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: widget.todoViewModel,
          builder: (context, _) {
            if (widget.todoViewModel.error != null) {
              return Center(
                child: Text('에러 발생: ${widget.todoViewModel.error}'),
              );
            }

            if (widget.todoViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.todoViewModel.cachedTodos.isEmpty) {
              return const Center(
                child: Text(
                  "작성된 할 일이 없습니다\n추가해주세요",
                  style: TextStyle(
                    fontSize: 17,
                    color: AppTheme.textColor2,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return TabBarView(
              children: [
                _buildTodoList(
                  _sortInProgressTodos(
                      widget.todoViewModel.cachedTodos.values
                          .where((todo) => todo.isDone == false)
                          .toList(),
                      isLatestSort),
                ),
                _buildTodoList(
                  _sortDoneTodos(
                      widget.todoViewModel.cachedTodos.values
                          .where((todo) => todo.isDone == true)
                          .toList(),
                      isLatestSort),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          backgroundColor: AppTheme.backgroundColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
              side: const BorderSide(
                color: AppTheme.additionalColor,
                width: 2.0,
              )),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppTheme.textColor1),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  @override
  void dispose() {
    // widget.todoViewModel.dispose();
    widget.todoViewModel.removeListener(_todoListener);
    super.dispose();
  }
}
