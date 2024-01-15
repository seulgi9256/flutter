import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }

}

// "_클래스" dart 파일 내부에서만 사용하는 클래스
class _MyApp extends State<MyApp> {

  // state
  var switchValue = false;
  Color _color = Colors.black;
  String _button = 'test';


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,    // 디버그 리본 숨기기
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.light(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: 메인(홈) 화면을 지정하는 속성
      home: Scaffold(
              body : Center(
                        child: 
                          ElevatedButton(
                            child: Text(_button),
                            style: ButtonStyle(
                                      // 버튼 배경색
                                      backgroundColor: MaterialStateProperty.all(_color),
                                      // 글씨 색
                                      foregroundColor: MaterialStateProperty.all(Colors.white)
                            ),
                            onPressed: () { 
                                print('test 클릭!');

                                if( _color == Colors.black ) {
                                  setState(() {
                                    _color = Colors.red;
                                    _button = 'hello';
                                  });
                                } else {
                                  setState(() {
                                    _color = Colors.black;
                                    _button = 'test';
                                  });
                                }
                            },
                          
                          )

                    )
            )
      
      
      
    );
  }


}

