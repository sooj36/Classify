import 'package:flutter/material.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final List<Map<String, dynamic>> categories = [
    {'name': '상의', 'icon': Icons.local_laundry_service},
    {'name': '하의', 'icon': Icons.layers},
    {'name': '아우터', 'icon': Icons.dry_cleaning},
    {'name': '신발', 'icon': Icons.hiking},
    {'name': '모자', 'icon': Icons.face},
    {'name': '액세서리', 'icon': Icons.watch},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 옷장', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                // TODO: 카테고리 탭 처리
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categories[index]['icon'],
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index]['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}