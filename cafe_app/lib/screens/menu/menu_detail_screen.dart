import 'package:cafe_app/models/coffee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuDetailScreen extends StatefulWidget {
  final Coffee item;
  const MenuDetailScreen({super.key, required this.item});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  // state
  String? type = 'hot';     // ice/hot

  @override
  Widget build(BuildContext context) {
    Coffee coffee = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text("커피"),
        centerTitle: true,
        backgroundColor: Colors.black12,
        leading: BackButton(
          color: Colors.grey,
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.home, color: Colors.black,),
            ) 
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              children: [
                // Rounded Rectangle Clip 
                // - 둥근 사각형 위젯
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset(
                    // hot / ice
                    type == 'hot' 
                      ? "${coffee.imageUrl}"
                      : "${coffee.imageUrl2}",
                    width: 240.0,
                    height: 240.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.0,),
                Text(
                    "${coffee.title}",
                    style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 10.0,),
                Text(
                    "${NumberFormat
                            .decimalPattern()
                            .format(coffee.price) }원",
                    style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Divider(),
          // 옵션 선택 영역
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text("온도"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: Text("hot"), 
                    selected: type == 'hot',
                    onSelected: (selected) {
                        setState(() {
                          type = 'hot';
                        });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: type == 'hot' ? Colors.purple : Colors.grey
                      )
                    ),
                  ),
                  ChoiceChip(
                    label: Text("ice"), 
                    selected: type == 'ice',
                    onSelected: (selected) {
                        setState(() {
                          type = 'ice';
                        });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: type == 'hot' ? Colors.purple : Colors.grey
                      )
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
      // -------------------  body ------------------------
      bottomNavigationBar: BottomAppBar(
        color: Colors.amber,
        child: Row(
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              color: Colors.red,
            ),
            // 최대 너비를 사용하는 위젯
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "${NumberFormat.decimalPattern().format(coffee.price)} 원",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              )
            ),
            TextButton(
              child: Text(
                "주문하기",
                style: TextStyle(color: Colors.red, fontSize: 22.0),
              ),
              onPressed: () {
                // 버튼 클릭 시, "주문이 완료되었습니다"
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("${coffee.title}"),
                      content: Text("${coffee.price} 원 입니다."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: Text("취소"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: Text("확인"),
                        ),
                      ],
                    );
                  }
                );
              },
            )
          ],
        ),
      ),

    );
  }
}