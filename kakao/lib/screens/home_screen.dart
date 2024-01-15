import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao/provider/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 페이지'),
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
                Text("카카오 로그인하기")
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
              Navigator.pushReplacementNamed(context, "/login");
            },

          ),
        ),
      ),
    );
  }
}