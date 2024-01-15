import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 페이지'),
        backgroundColor: Colors.brown,
        titleTextStyle: GoogleFonts.jua(
          fontSize: 30,
          fontWeight: FontWeight.normal,
          color: Colors.white70
        ),
      ),
      body: Consumer<UserProvider>(
            builder: (context, user, child) => 
               Container(
                child: Center(
                  
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network('${user.userInfo.kakaoAccount?.profile?.thumbnailImageUrl}'),
                        Text('${user.userInfo.kakaoAccount?.profile?.nickname}'),
                        ElevatedButton(
                          child: Text(
                                !user.isLogin ? '카카오 로그인' : '로그아웃'
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
                            // 카카오 로그인 요청
                            // provider 로 부터 사용자 정보 가져와서 확인
                            var user = context.read<UserProvider>();

                            // ✔ 로그인 여부 확인
                            user.loginCheck();

                            // 비로그인 시 ➡ 로그인 요청
                            if( !await user.isLogin ) {
                              // 사용자 조건 : 카카오톡 설치 여부
                              await isKakaoTalkInstalled() ? user.kakaoTalkLogin() : user.kakaoLogin();
                            }
                            else {
                              // 이미 로그인된 상태 ➡ 로그인 화면
                              Navigator.pushReplacementNamed(context, "/logout");
                            }

                          },

                        ),
                        
                      ],
                    ),
                  )
                  
                ),
              ),
              
            ),
      
     
    );
  }
}