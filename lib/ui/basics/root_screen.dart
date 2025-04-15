import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weathercloset/routing/routes.dart';

class RootScreen extends StatefulWidget {
const RootScreen({super.key, required this.child});
  final Widget child;
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    debugPrint("✅ 루트 스크린 초기화");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          context.go(Routes.archive);
        case 1:
          context.go(Routes.sendMemo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classify", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // context.push(Routes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(Routes.setting);
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: '메모'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}