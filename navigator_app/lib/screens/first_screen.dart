
import 'package:flutter/material.dart';
import 'package:navigator_app/models/user.dart';
import 'package:navigator_app/screens/animate_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User user = User(id: 'joeun', name: '김조은');

    return Scaffold(
        appBar: AppBar(title: const Text('첫 페이지')),
        body: const Center(
          child: const Text('첫 페이지'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 페이지 이동하기 (1 ➡ 2)
            // Navigator.push(
            //   context, 
            //   MaterialPageRoute<void>(
            //     // 페이지 이동 시, 
            //     // 생성자의 매개변수를 통해서 데이터를 전달
            //     // builder: (BuildContext context) => const SecondScreen(data: '넘겨준 데이터'),
            //     builder: (BuildContext context) => SecondScreen(user: user),
            //   ),
            // );
            // 애니메이션 이동
            Navigator.push(context, _createRoute());
          },
          child: const Icon(Icons.arrow_forward),
        ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      // 이동할 페이지 지정
      pageBuilder: (context, animation, secondaryAnimation) => const AnimateScreen(),

      // 애니메이션 지정
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Offset(x축, y축)  : 0.0 ~ 1.0
        const begin = Offset(0.0, 1.0);     // 시작점 
        const end = Offset.zero;            // 끝점
        const curve = Curves.ease;          // 애니메이션 속도 곡선

        // Tween : 애니메이션을 적용하는 설정 객체
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        // 위젯을 애니메이션을 통해 이동시키는 객체
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


}