
import 'package:flutter/material.dart';

class AnimateScreen extends StatelessWidget {
  const AnimateScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: const Text('애니메이션 페이지')),
        body: const Center(
          child: const Text('애니메이션 페이지'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 페이지 돌아가기
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_forward),
        ),
    );
  }
}