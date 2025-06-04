import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:intl/intl.dart';
import 'package:classify/ui/today_act/view_models/today_act_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';

class MemoDetailPage extends StatefulWidget {
  final MemoModel memo;
  final TodayActViewModel viewModel;

  const MemoDetailPage({
    super.key, 
    required this.memo,
    required this.viewModel,
  });

  @override
  State<MemoDetailPage> createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends State<MemoDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late DateTime _createdAt;
  late List<String> _tags;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo.title);
    _contentController = TextEditingController(text: widget.memo.content);
    _tagController = TextEditingController();
    _createdAt = widget.memo.createdAt;
    _tags = widget.memo.tags?.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // 수정된 메모 모델 생성
  MemoModel _getUpdatedMemo() {
    return widget.memo.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      tags: _tags,
      lastModified: DateTime.now(),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디어 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          //삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmDialog();
            },
          ),
          //수정 버튼
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // 편집 모드 종료 시 저장
                  final updatedMemo = _getUpdatedMemo();
                  widget.viewModel.updateMemo(updatedMemo);
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            TextField(
              controller: _titleController,
              enabled: _isEditing,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '제목',
                filled: false
              ),
            ),
            const Divider(),
            
            // 카테고리
            Row(
              children: [
                const Icon(Icons.category, size: 18, color: AppTheme.textColor1),
                const SizedBox(width: 8),
                Text(
                  widget.memo.category,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textColor1),
                ),
              ],
            ),
            
            // 생성 시간
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: AppTheme.textColor1),
                const SizedBox(width: 8),
                Text(
                  '생성: ${DateFormat('yyyy-MM-dd HH:mm').format(_createdAt)}',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textColor1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 태그
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.tag, size: 18, color: AppTheme.textColor1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) => _buildTagChip(tag)).toList(),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tagController,
                          onSubmitted: _addTag,
                          decoration: const InputDecoration(
                            hintText: '새 태그 추가 (입력 후 엔터)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: false
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            
            // 내용
            TextField(
              controller: _contentController,
              enabled: _isEditing,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '내용을 입력하세요',
                filled: false
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(fontSize: 14),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _removeTag(tag),
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  // 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이디어 삭제'),
        content: const Text('이 아이디어를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              widget.viewModel.deleteMemo(widget.memo.memoId, widget.memo.category);
              Navigator.pop(context); // 상세 페이지 닫기
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
