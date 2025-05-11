import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';

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
    });
    // 리스너 추가
    widget.todoViewModel.addListener(_todoListener);
  }

  void _todoListener() {
    if (mounted) {
      _sortTodos();
      setState(() {});
    }
  }

  void _sortTodos() {
    if (widget.todoViewModel.cachedTodos.isNotEmpty) {
      latestTodos =
          List<TodoModel>.from(widget.todoViewModel.cachedTodos.values)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      oldestTodos =
          List<TodoModel>.from(widget.todoViewModel.cachedTodos.values)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  void _showAddTodoDialog() {
    final TextEditingController todoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('할 일 추가'),
          content: TextField(
            controller: todoController,
            decoration: const InputDecoration(
              hintText: '할 일을 입력하세요',
            ),
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
                  widget.todoViewModel.createTodo(todoController.text);
                  Navigator.pop(context);
                  setState(() {
                    _sortTodos();
                  });
                }
              },
              child: const Text('추가'),
            ),
          ],
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
                      _sortTodos();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "할 일이 없습니다",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) =>
          todoCards(context, todos[index], onTaskCompleted: (todoId) {
        widget.todoViewModel.toggleTodoStatus(todoId);
        setState(() {
          // _sortTodos();
        });
      }),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0, // 가로 간격
        mainAxisSpacing: 10.0, // 세로 간격
        childAspectRatio: 1.0, // 가로:세로 비율
      ),
    );
  }

  Widget todoCards(BuildContext context, TodoModel todo,
      {required Function(String) onTaskCompleted}) {
    return InkWell(
      onTap: () {
        _showEditTodoDialog(todo);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            // 체크박스 (왼쪽 상단)
            Positioned(
              top: 8,
              left: 8,
              child: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: todo.isDone,
                  onChanged: (bool? value) {
                    // if (value == true) {
                    widget.todoViewModel.toggleTodoStatus(todo.todoId);
                    // }
                  },
                ),
              ),
            ),

            // 할 일 내용 (중앙)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
              child: Center(
                child: Text(
                  todo.todoContent,
                  style: const TextStyle(fontSize: 15.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // 시간 (오른쪽 하단)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatDateTime(todo.lastModified ?? todo.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: AppTheme.decorationColor1,
          bottom: const TabBar(
            indicatorColor: AppTheme.additionalColor,
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
                    Icon(Icons.pending_actions),
                    SizedBox(width: 8),
                    Text('IN PROGRESS'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt),
                    SizedBox(width: 8),
                    Text('DONE'),
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
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            // _sortTodos();

            return TabBarView(
              children: [
                _buildTodoList(
                  isLatestSort
                      ? latestTodos
                          .where((todo) => todo.isDone == false)
                          .toList()
                      : oldestTodos
                          .where((todo) => todo.isDone == false)
                          .toList(),
                ),
                _buildTodoList(
                  isLatestSort
                      ? latestTodos
                          .where((todo) => todo.isDone == true)
                          .toList()
                      : oldestTodos
                          .where((todo) => todo.isDone == true)
                          .toList(),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          backgroundColor: AppTheme.secondaryColor1,
          child: const Icon(Icons.add_box_sharp),
        ),
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
