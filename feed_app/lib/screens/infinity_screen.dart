import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfinityScreen extends StatefulWidget {
  const InfinityScreen({super.key});

  @override
  State<InfinityScreen> createState() => _InfinityScreenState();
}

class _InfinityScreenState extends State<InfinityScreen> {

  List<String> items = [];
  // List<String> items 
  // = [
  //    'item1','item2','item3','item4','item5',
  //    'item6','item7','item8','item9','item10',
  //    'item1','item2','item3','item4','item5',
  //    'item6','item7','item8','item9','item10',
  //   ];

  final ScrollController _controller = ScrollController();

  int _page = 1;
  Map<String,dynamic> _pageObj = {'last':0};

  @override
  void initState() {
    super.initState();

    // 처음 데이터
    fetch();
    
    // 다음 페이지 (스크롤)
    _controller.addListener(() { 
      // 스크롤 맨 밑
      // _controller.position.maxScrollExtent : 스크롤 위치의 최댓값
      // _controller.position.offset          : 현재 스크롤 위치
      print('현재 스크롤 : ${_controller.offset}');
      
      if(_controller.position.maxScrollExtent < _controller.offset + 50) {
        // 데이터 요청 (다음 페이지)
        fetch();
      }
    });
  }

  Future fetch() async {
    print('fetch...');
    // http 
    // 1. URL 인코딩
    // 2. GET 방식 요청
    // final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

    final url = Uri.parse('http://10.0.2.2:8080/board?page=${_page}');
    final response = await http.get(url);

    if( response.statusCode == 200 ) {
      setState(() {
        // items.addAll(['New']);

        // JSON 문자열 ➡ List<>
        var utf8Decoded = utf8.decode( response.bodyBytes );
        var result = json.decode(utf8Decoded);
        final page = result['page'];
        final List list = result['list'];
        // final List newData = json.decode(utf8Decoded);
        print('page : ');
        print(page);
        _pageObj = page;

        items.addAll( list.map<String>((item) {
          // Map<String, ?>  : 요소 접근 - item.['key']
          // Item (id, title, body)
          // final id = item['id'];

          final boardNo = item['boardNo'];
          final title = item['title'];
          return 'Item $boardNo - $title';
        }));

        // 다음 페이지
        _page++;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inifinity Scroll'),),
      body: 
      ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(8, 60, 8, 8),
        itemBuilder: (context, index) {
          // index: 0~19
          if( index < items.length ){
            final item = items[index];
            return ListTile(title: Text(item),);
          } 
          // index: 20
          else if( (_page-1) > 1 && _page < _pageObj['last']! ) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
        itemCount: items.length + 1,  // ProgressIndicator(+1)
      )
      
    );
  }
}