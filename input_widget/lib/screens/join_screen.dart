import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}


class _JoinScreenState extends State<JoinScreen> {

  // state
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwChkController = TextEditingController();
  String _gender = '남자';
  final TextEditingController _birthController = TextEditingController();
  String _idType = '주민등록증';
  final _formKey = GlobalKey<FormState>();

  // 달력
  // state
  List<DateTime?> _dateDefaultValue = [
    DateTime.now(),
  ];

  // 입력 날짜
  String _date = '';      // 2023/01/01 ~ 2023/01/05

  // 수량
  final TextEditingController _countController = TextEditingController(text: '1');
  int _count = 1;
  final int _maxCount = 100;
  final int _minCount = 1;

  

  
  


  // 달력 설정
  // 설정 정보
  final config = CalendarDatePicker2Config(
        // 캘린더 타입 : single, multi, range
        calendarType: CalendarDatePicker2Type.range,
        selectedDayHighlightColor: Colors.amber[900],
        weekdayLabels: ['일', '월', '화', '수', '목', '금', '토'],
        weekdayLabelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        firstDayOfWeek: 0,      // 시작 요일 : 0 (일), 1(월)
        controlsHeight: 50,
        controlsTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        disabledDayTextStyle: const TextStyle(
          color: Colors.grey,
        ),
        selectableDayPredicate: (day) => !day
            .difference(DateTime.now().subtract(const Duration(days: 3)))
            .isNegative,
      );



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ListView(
        children: [
          Text(
            '회원가입', 
            style: TextStyle(fontSize: 30.0),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // 아이디
                TextFormField(
                  autofocus: true,
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: '아이디'
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return '아이디를 입력하세요.';
                    }
                    return null;
                  },
                  
                ),
                const SizedBox(height: 20.0,),
                // 비밀번호
                TextFormField(
                  obscureText: true,
                  controller: _pwController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호'
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    return null;
                  },
                  
                ),
                const SizedBox(height: 20.0,),
                // 비밀번호 확인
                TextFormField(
                  obscureText: true,
                  controller: _pwChkController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 확인'
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력하세요.';
                    }
                    return null;
                  },
                  
                ),
                const SizedBox(height: 20.0,),
                // 성별
                Row(
                  children: [
                    Text('성별'),
                    Radio(
                      value: '남자',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _gender = '남자';
                        });
                      },
                      child: Text('남자'),
                    ),
                    Radio(
                      value: '여자',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value.toString();
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _gender = '여자';
                        });
                      },
                      child: Text('여자'),
                    ),
                    
                  ],
                ),
                // 생년월일
                Column(
                  children: [
                      TextFormField(
                        // initialValue: '2023-01-01',
                        controller: _birthController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '생년월일',
                          suffixIcon: GestureDetector(
                                        onTap: () {
                                            picker.DatePicker.showDatePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime(1900, 1, 1),
                                              maxTime: DateTime.now(),
                                              theme: const picker.DatePickerTheme(
                                                  // 헤더
                                                  // headerColor: Colors.orange,
                                                  // 배경
                                                  // backgroundColor: Colors.blue,
                                                  // 항목
                                                  itemStyle: TextStyle(
                                                      // color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18),
                                                  // 완료
                                                  doneStyle:
                                                      TextStyle(color: Colors.black, fontSize: 16)),
                                              onChanged: (date) {
                                                print('change $date in time zone ' +
                                                    date.timeZoneOffset.inHours.toString());

                                                print('생년월일 : ${_birthController.text}');
                                                print(date);

                                              }, onConfirm: (date) {
                                                print('confirm $date');
                                                // 2023/01/01
                                                
                                                var dateFormat = DateFormat('yyyy/MM/dd').format(date);
                                                _birthController.text = dateFormat;
                                                
                                              }, 
                                          currentTime: DateTime.now(), locale: picker.LocaleType.ko);
                                        },
                                        child: Icon(Icons.calendar_month),
                                      ),
                          
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return '생년월일을 입력하세요.';
                          }
                          return null;
                        },
                      ),
                      // 신분증 종류
                      DropdownButtonFormField(
                        decoration: const InputDecoration(labelText: '신분증 종류'),
                        value: _idType,
                        items: ['주민등록증', '운전면허증', '여권'].map((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList()
                        , 
                        onChanged: (value) {
                          setState(() {
                            _idType = value!;
                          });
                        },
                        
                      ),
                      const SizedBox(height: 20.0,),

                      // 달력
                      const Text('출발일자 ~ 도착일자:'),
                      CalendarDatePicker2(
                        config: config,
                        value: _dateDefaultValue,
                        onValueChanged: (dates) {
                            // multi
                            // 2개만 선택
                            // if( dates.length > 2 ) {
                            //   setState(() {
                            //     _dateDefaultValue = [];
                            //   });
                            //   return;
                            // }
                            setState(() => _dateDefaultValue = dates);
                            print('달력 날짜 : ${dates}');

                            // 2023/01/01 ~ 2023/01/06 포맷팅
                            var start = DateFormat('yyyy/MM/dd').format(dates[0]!);
                            var end = DateFormat('yyyy/MM/dd').format(dates[1]!);
                            var date = '${start} ~ ${end}';
                            setState(() {
                              _date = date;
                            });
                        }
                      ),
                      const SizedBox(height: 20.0,),
                      // 수량 
                      const Text('수량:'),
                      TextField(
                        
                        textAlign: TextAlign.center,
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          prefixIcon: ElevatedButton(
                                        onPressed: () {
                                          // // 방법 1
                                          // // String ➡ int
                                          // int newCount = int.tryParse(_countController.text) ?? 1;
                                          // newCount++;
                                          // // int ➡ String
                                          // _countController.text = newCount.toString();

                                          // 방법 2
                                          if( _maxCount < _count ) {
                                            return;
                                          }
                                          setState(() {
                                            _count++;
                                          });                  
                                          _countController.text = _count.toString();
                                        }, 
                                        child: Text('+'),
                                      ),
                          suffixIcon: ElevatedButton(
                                        onPressed: () {
                                          if( _minCount >= _count ) {
                                            return;
                                          }
                                          setState(() {
                                            _count--;
                                          });                  
                                          _countController.text = _count.toString();
                                        }, 
                                        child: Text('-'),
                                      ),
                        ),
                        onChanged: (value) {
                          // int.parse("10") : String ➡ int 로 변환
                          // int.parse("")   : 빈 문자열을 int 변환하면 예외발생
                          // int.tryParse("숫자가아닌문자열") ➡ 예외 대신 null 로 반환
                          int newValue = int.tryParse(value) ?? -1;
                          // 값이 없을 때
                          if( newValue == -1 ) { 
                            setState(() { _count = 1; });
                            return; 
                          } 
                          if( newValue >= _maxCount ) {newValue = _maxCount;}
                          if( newValue < _minCount ) {newValue = _minCount;}
                          setState(() {
                            _count = newValue;
                          });
                          _countController.text = newValue.toString();
                        },
                      ),
                      
                      

                      const SizedBox(height: 20.0,),
                      // 회원가입 버튼
                      ElevatedButton(
                        onPressed: () {
                          if( _formKey.currentState!.validate() ) {
                            // 데이터 요청
                            print('아이디 : ${_idController.text}');
                            print('비밀번호 : ${_pwController.text}');
                            print('비밀번호 확인 : ${_pwChkController.text}');
                            print('성별 : ${_gender}');
                            print('생년월일 : ${_birthController.text}');
                            print('신분증 종류 : ${_idType}');
                            print('선택 날짜 : ${_date}');
                            print('수량 : ${_countController.text}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0)
                          ),
                          minimumSize: const Size(double.infinity, 40.0)
                        ),
                        child: const Text('회원가입'),
                      ),
                  ],
                ),
              ],
            ),
          )
        ]
      ),
    )
    
    ;
  }
}