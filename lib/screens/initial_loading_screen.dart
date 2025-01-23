import 'dart:async';
import 'package:weathercloset/global/global.dart';
import 'package:flutter/material.dart';
import 'package:weathercloset/test.dart';

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
              Color.fromARGB(255, 207, 70, 241),
              Color.fromARGB(255, 72, 70, 228),
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset("assets/images/welcome.png"),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if (firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TestWidget(text: 'weatherCloset')));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const TestWidget(text: 'authscreen')));
      }
    });
  }


}
