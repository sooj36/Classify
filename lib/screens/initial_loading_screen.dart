import 'dart:async';
import 'package:weathercloset/global/global.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/test.dart';
import 'package:weathercloset/top_level_setting.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {

  @override
  void initState() {
    startTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: const Center(
          child: Text("weatherCloset"),
        ),
      ),
    );
  }

  startTimer() {
    Timer(const Duration(seconds: 2), () async {
      if (firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TestWidget(text: 'weatherCloset')));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TestWidget(text: 'authscreen')));
      }
    });
  }


}
