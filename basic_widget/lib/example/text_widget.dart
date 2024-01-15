import 'package:flutter/material.dart';


class TextWidget extends StatelessWidget {
  const TextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return 
        const Scaffold(
          body: Center(
            // Text( 텍스트, 스타일 )
            child: Text(
              "텍스트 위젯입니다.",
              style: TextStyle(
                fontSize: 30.0,                             // double
                fontWeight: FontWeight.bold,                // FontWeight
                // color: Color.fromRGBO(255, 0, 0, 0.5),
                color: Colors.red,
              ),
            ),
          ),
        );
  }
  
}
