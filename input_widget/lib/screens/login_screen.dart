import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // state
  bool rememberId = false;
  bool rememberMe = false;



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          const Text(
            '로그인',
            style: TextStyle(fontSize: 32.0),
          ),
          const SizedBox(height: 50,),
          const TextField(
                    obscureText: false,       // 비밀 기호로 표시 여부
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '아이디',
                    ),
          ),
          const SizedBox(height: 20,),
          const TextField(
                    obscureText: true,       // 비밀 기호로 표시 여부
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '비밀번호',
                    ),
          ),
          const SizedBox(height: 20,),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberId, 
                      onChanged: (bool? value) { 
                        print('아이디 저장 : ${value}');
                        setState(() {
                          rememberId = value!;
                        });

                      }
                    ),
                    const Text('아이디 저장'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe, 
                      onChanged: (bool? value) { 
                        print('자동 로그인 : ${value}');
                        setState(() {
                          rememberMe = value!;
                        });

                      }
                    ),
                    const Text('자동 로그인'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0)
              ),
              minimumSize: const Size(double.infinity, 40.0)
            ),
            // ButtonStyle(
            //   backgroundColor: MaterialStateProperty.all(Colors.black),
            //   foregroundColor: MaterialStateProperty.all(Colors.white),
            //   shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular( 0.0 ),
            //   )),
            //   minimumSize: 
            //     MaterialStateProperty.all(const Size(double.infinity, 40.0)),
            // ), 
            child: const Text('로그인'),
            

          ),
          

        ]
      ),
    );
  }
}