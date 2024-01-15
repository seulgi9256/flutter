import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }

}

// "_클래스" dart 파일 내부에서만 사용하는 클래스
class _MyApp extends State<MyApp> {

  var switchValue = false;
   // This widget is the root of your application.
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
                        // 텍스트 위젯
                        // child: Text('Hello Flutter'
                        //             , textAlign: TextAlign.center
                        //             , style: TextStyle(color: Colors.blue, fontSize: 20),
                        //            )

                        child: Switch(
                          value: switchValue,  // false
                          onChanged: (value){
                                      // switchValue = !switchValue;
                                      // print(switchValue);
                                      // print('test...');
                                      setState(() {
                                        switchValue = value;
                                      });

                                   }
                        )

                    )
            )
      
      
      
    );
  }

}

