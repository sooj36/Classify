import 'package:flutter/material.dart';
import 'package:weathercloset/screens/setting_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WeatherCloset", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to WeatherCloset!"),
      ),
    );
  }
}