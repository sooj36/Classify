import 'package:flutter/material.dart';
import 'package:classify/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';
import 'package:classify/utils/top_level_setting.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 자동으로 키보드가 올라오도록 설정
      _memoFocusNode.requestFocus();
    });

    // 텍스트 변경 리스너 추가
    _memoController.addListener(_updateCharCount);
  }

  @override
  void dispose() {
    _memoController.removeListener(_updateCharCount);
    _memoController.dispose();
    _memoFocusNode.dispose();
    super.dispose();
  }

  // 글자 수 업데이트를 위한 리스너
  void _updateCharCount() {
    setState(() {
      // 글자 수 상태 업데이트
    });
  }

  // 메모 저장 함수 - Optimistic UI 적용
  void _saveMemo() {
    final text = _memoController.text.trim();
    if (text.isEmpty) {
      return;
    }

    // 즉시 화면 닫기 (Optimistic UI)
    Navigator.pop(context);

    // 백그라운드에서 메모 처리 진행
    _processMemoInBackground(text);
  }

  // 백그라운드에서 메모 처리
  Future<void> _processMemoInBackground(String text) async {
    try {
      await widget._sendMemoToAiViewModel.sendMemoToAi(text);

      // 현재 화면은 이미 닫혔으므로 다른 방식으로 피드백 제공 필요
      if (widget._sendMemoToAiViewModel.error != null) {
        // 필요시 에러 처리 로직 추가 (예: 글로벌 스낵바, 로깅 등)
        debugPrint("메모 저장 중 오류: ${widget._sendMemoToAiViewModel.error}");
      }
    } catch (e) {
      debugPrint("메모 저장 중 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ActionChip(
              label: const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.backgroundColor,
                ),
              ),
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.textColor1, width: 1),
              ),
              onPressed: _saveMemo,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _memoController,
                  focusNode: _memoFocusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: '텍스트를 입력해주세요...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ),

            // 글자 수 카운터 및 안내 메시지
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_memoController.text.length} 자',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // 에러 메시지 표시
            ListenableBuilder(
              listenable: widget._sendMemoToAiViewModel,
              builder: (context, _) {
                final error = widget._sendMemoToAiViewModel.error;
                return error != null
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
