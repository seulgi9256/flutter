
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class UserProvider extends ChangeNotifier {
  // 로그인 정보
  late User _userInfo;
  // 로그인 상태
  bool _loginStat = false;

  // getter
  // get : getter 메소드를 정의하는 키워드
  User get userInfo => _userInfo;       // 전역변수
  bool get isLogin => _loginStat;       // 전역변수



  // 카카오 로그인 요청
  Future<void> kakaoLogin() async {
    try {
      // 로그인 요청 ➡ token
      // loginWithKakaoAccount() : 카카오 계정으로 로그인
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('로그인 성공...');
      print('${token.accessToken}');      

      _loginStat = true;       // 로그인 여부 : true
      getUserInfo();           // 사용자 정보 가져오기

    } catch (error) {
      print("카카오 계정으로 로그인 실패 $error");
    }
    // 공유된 상태를 가진 위젯 다시 빌드
    notifyListeners();   
  }


  // 카카오톡 로그인 요청
  Future<void> kakaoTalkLogin() async {
    try {
      // 로그인 요청 ➡ token
      // loginWithKakaoAccount() : 카카오 계정으로 로그인
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      print('카카오톡으로 로그인 성공...');
      print('${token.accessToken}');      

      _loginStat = true;       // 로그인 여부 : true
      getUserInfo();           // 사용자 정보 가져오기

    } catch (error) {
      print("카카오톡으로 로그인 실패 $error");
    }
    // 공유된 상태를 가진 위젯 다시 빌드
    notifyListeners();   
  }

  // 사용자 정보 가져오기
  Future<void> getUserInfo() async {
    try {
      _userInfo = await UserApi.instance.me();
      print('사용자 정보 요청 성공');
      print('userInfo : ${_userInfo}');
      print('id : ${_userInfo.id}');
      print('nickname : ${_userInfo.kakaoAccount?.profile?.nickname}');
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
    notifyListeners();
  }

  // 로그인 확인
  Future<void> loginCheck() async {

    // 🔓비로그인 - _loginStat : false
    if( !_loginStat ) return; 

    // 🔐로그인
    // - 이미 로그인 인증 받은 정보가 저장되어있는 케이스
    if( await AuthApi.instance.hasToken() ) {
      try {
        // 토큰 확인
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        print('토큰 유효성 체크 성공 ${tokenInfo.id} - ${tokenInfo.expiresIn}');
        _loginStat = true;
      } catch (error) {
        // 카카오 예외, 토큰 만료여부
        if( error is KakaoException && error.isInvalidTokenError() ) {
          print('토큰 만료 - $error');
        } else {
          print('토큰 정보 확인 실패 $error');
        }
        _loginStat = false;
      }
    }
    else {
      print('발급된 토큰 없음');
      _loginStat = false;
    }

    notifyListeners();
  }

  // 로그아웃
  Future<void> kakaoLogout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공');
      _loginStat = false;
    } catch (error) {
      print('로그아웃 실패');
    }
    notifyListeners();
  }




}