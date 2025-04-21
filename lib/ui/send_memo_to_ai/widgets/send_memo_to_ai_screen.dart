import 'package:flutter/material.dart';
import 'package:weathercloset/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';

class SendMemoToAiScreen extends StatefulWidget {
  final SendMemoToAiViewModel _sendMemoToAiViewModel;

  const SendMemoToAiScreen({
    super.key,
    required SendMemoToAiViewModel sendMemoToAiViewModel,
  }) : _sendMemoToAiViewModel = sendMemoToAiViewModel;

  @override
  State<SendMemoToAiScreen> createState() => _SendMemoToAiScreenState();
}

class _SendMemoToAiScreenState extends State<SendMemoToAiScreen> {
  final TextEditingController _memoController = TextEditingController();
  final FocusNode _memoFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 자동으로 텍스트필드에 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    _memoFocusNode.dispose();
    super.dispose();
  }

  // 메모 저장 함수
  Future<void> _saveMemo() async {
    final text = _memoController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget._sendMemoToAiViewModel.sendMemoToAi(text);
      
      if (mounted) {
        // 저장 성공 시 화면 닫기
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 메모'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : TextButton(
                  onPressed: _saveMemo,
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _memoController,
                focusNode: _memoFocusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '메모를 입력하세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}