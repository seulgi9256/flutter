
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http_app/models/board.dart';

class ReadScreen extends StatefulWidget {
  final Board board;
  const ReadScreen({super.key, required this.board});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.title ?? '제목'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: '수정하기',
                  child: Text('수정하기'),
                  onTap: () {},
                ),
                PopupMenuItem(
                  value: '삭제하기',
                  child: Text('삭제하기'),
                  onTap: () {},
                ),
              ];
            }
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(widget.board.writer ?? '작성자'),
              ),
            ),
            SizedBox(height: 10.0,),
            Container(
                padding: EdgeInsets.all(12.0),
                color: Color.fromRGBO(125, 125, 200, 0.3),
                width: double.infinity,
                height: 320.0,
                child: SingleChildScrollView(
                        child: Text(widget.board.content ?? '내용')
                       )
            ),
            

            
          ]
        ),
      ),
    );
  }
}