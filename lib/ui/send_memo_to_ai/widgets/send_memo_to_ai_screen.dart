import 'package:flutter/material.dart';
import 'package:weathercloset/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';

class SendMemoToAiScreen extends StatefulWidget {
  final SendMemoToAiViewModel _sendMemoToAiViewModel;

  const SendMemoToAiScreen({super.key,
  required SendMemoToAiViewModel sendMemoToAiViewModel,
  }) : _sendMemoToAiViewModel = sendMemoToAiViewModel;

  @override
  State<SendMemoToAiScreen> createState() => _SendMemoToAiScreenState();
}

class _SendMemoToAiScreenState extends State<SendMemoToAiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Center(child: Text("SendMemoToAiScreen")),
      ),
    );
  }



}