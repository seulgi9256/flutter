import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그아웃 페이지'),
        backgroundColor: Colors.brown,
        titleTextStyle: GoogleFonts.jua(
          fontSize: 30,
          fontWeight: FontWeight.normal,
          color: Colors.white70
        ),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            child: Consumer<UserProvider>(
              builder: (context, user, child) => 
                Text("카카오 로그아웃")
              ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
              elevation: 5
            ),
            onPressed: () async {
              // 카카오 로그아웃 요청
              var user = context.read<UserProvider>();
              if(user.isLogin) {
                user.kakaoLogout();
                print('카카오 로그아웃 완료...');
              }
              Navigator.pushReplacementNamed(context, '/login');
            },

          ),
        ),
      ),
    );
  }
}