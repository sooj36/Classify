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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
          child: Column(
          children: [
            _buildMemoTextField(),
            const SizedBox(height: 15),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), 
            blurRadius: 8, 
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 3),
          const Text(
            '메모 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 메모 입력 텍스트 필드
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _memoController,
              maxLines: 5,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                hintText: '200자 이내로 입력해주세요.',
                contentPadding: EdgeInsets.all(16),
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 정리하기 버튼
          ElevatedButton(
            onPressed: () {
              if (_memoController.text.trim().isNotEmpty) {
                // widget._sendMemoToAiViewModel.sendMemoToAi(_memoController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '정리하기',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '도움말',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '링크를 넣으면 웹사이트 아카이빙도 가능합니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}