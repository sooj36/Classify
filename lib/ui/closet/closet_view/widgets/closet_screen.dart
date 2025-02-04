import 'package:flutter/material.dart';
import '../../../../routing/router.dart';
import '../../../../routing/routes.dart';
import '../view_models/closet_view_model.dart';

class ClosetScreen extends StatefulWidget {
  final ClosetViewModel viewModel;
  const ClosetScreen({super.key, required this.viewModel});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchClothes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: widget.viewModel.clothes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('옷장이 비어있습니다'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final cloth = snapshot.data![index];
              return ListTile(
                title: Text(cloth.major ?? ""),
                subtitle: Text(cloth.minor ?? ""),
                trailing: Text(cloth.color ?? ""),
              );
            },
          );
        }
      ),
       floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        onPressed: () {
          router.push(Routes.clothAdd);
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}















