import 'package:flutter/material.dart';
import 'package:kakao/screens/home_screen.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:kakao/provider/user_provider.dart';
import 'package:kakao/screens/login_screen.dart';
import 'package:kakao/screens/logout_screen.dart';
import 'package:provider/provider.dart';

void main() {

  // 카카오 sdk 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
      nativeAppKey: '6a8862a4ae3c9bc3e7011b6946538c97',
      javaScriptAppKey: '66058facfd88a9f609a6575f8ce1f38f',
  );


  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp()
    )
    
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/logout': (context) => LogoutScreen(),
      },
    );
  }
}
