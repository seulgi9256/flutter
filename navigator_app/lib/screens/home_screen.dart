
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈 화면')),
      body: Center(
        child: Text(
                  '홈 화면',
                  style: TextStyle(fontSize: 30.0),
              )
      ),
      bottomSheet: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                // 데이터 전달 : arguments 속성으로 전달
                Navigator.pushNamed(context, "/user", arguments: 'user');
              }, 
              child: Text('마이 페이지')
            ),
            ElevatedButton(
              onPressed: () {
                // 데이터 전달 : arguments 속성으로 전달
                Navigator.pushNamed(context, "/community", arguments: 'community');
              }, 
              child: Text('커뮤니티')
            ),
          ],
        ),
      ),
    );
  }
}