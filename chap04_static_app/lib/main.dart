import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('포켓몬'),
        ),
        body:  ListView(
          children: const [
            CardItem(
              imagePath: 'image/img01.jpg',
              title: '파이리',
              subtitle: '불 포켓몬',
            ),
            CardItem(
              imagePath: 'image/img02.jpg',
              title: '이상해씨',
              subtitle: '풀 포켓몬',
            ),
            CardItem(
              imagePath: 'image/img03.jpg',
              title: '꼬부기',
              subtitle: '물 포켓몬',
            ),
            // Add more CardItem widgets as needed
          ],
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const CardItem({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Diphylleia',
                fontSize: 24,
                color: Colors.orange,
              ),
            ),
            subtitle: Text(subtitle),
          ),
        ],
      ),
    );
  }
}
