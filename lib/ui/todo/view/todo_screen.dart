import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';

class TodoScreen extends StatefulWidget {
  final TodoViewModel viewModel;

  const TodoScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadTodoData();
      widget.viewModel.sortByLatest();
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

          final todoList = widget.viewModel.todoList;

          if (todoList.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTodoContent(todoList);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        backgroundColor: AppTheme.errorColor,
        child: const Icon(Icons.checklist, color: Colors.white),
      ),
    );
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
              '새로운 할 일을 추가하려면\n메모 작성 시 완료 여부를 체크하세요',
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

  Widget _buildTodoContent(List<MemoModel> todoList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildStatusFilter(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) => _buildTodoItem(todoList[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.viewModel.todoCount}개',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textColor2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Row(
      children: [
        for (final status in widget.viewModel.availableStatuses)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                status,
                style: TextStyle(
                  color: widget.viewModel.currentStatus == status
                      ? Colors.white
                      : AppTheme.textColor1,
                ),
              ),
              selected: widget.viewModel.currentStatus == status,
              onSelected: (selected) {
                if (selected) {
                  widget.viewModel.changeStatus(status);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryColor,
            ),
          ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            if (value == 'latest') {
              widget.viewModel.sortByLatest();
            } else {
              widget.viewModel.sortByOldest();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'latest',
              child: Text('최신순'),
            ),
            const PopupMenuItem(
              value: 'oldest',
              child: Text('오래된순'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodoItem(MemoModel todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isDone,
          activeColor: AppTheme.primaryColor,
          onChanged: (bool? value) {
            widget.viewModel.toggleTodoStatus(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: todo.isDone == true ? TextDecoration.lineThrough : null,
            color: todo.isDone == true ? Colors.grey : AppTheme.textColor1,
          ),
        ),
        subtitle: todo.content.isNotEmpty
            ? Text(
                todo.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  decoration:
                      todo.isDone == true ? TextDecoration.lineThrough : null,
                  color:
                      todo.isDone == true ? Colors.grey : AppTheme.textColor2,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteConfirmation(todo);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MemoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: Text('\'${todo.title}\' 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.viewModel.deleteTodo(todo.memoId);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 할일 추가 다이얼로그
  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 할일 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '할일 내용',
                  hintText: '상세 내용을 입력하세요',
                ),
                maxLines: 3,
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
                // 할일 생성 로직
                Navigator.pop(context);
                // 여기에 할일 생성 메서드 호출
                _addNewTodo(contentController.text.trim(), '');
              }
            },
            child: const Text('추가',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  // 새 할일 추가 메서드
  void _addNewTodo(String title, String content) {}
}
