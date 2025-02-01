import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  final String text;
  
  const TestWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}