import 'package:cafe_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Joeun Cafe',                        // 앱 이름
      debugShowCheckedModeBanner: false,          // debug 리본 비활성화
      home: MyHomePage(),
    );
  }
}
