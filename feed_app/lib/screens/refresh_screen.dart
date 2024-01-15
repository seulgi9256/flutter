import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RefreshScreen extends StatefulWidget {
  const RefreshScreen({super.key});

  @override
  State<RefreshScreen> createState() => _RefreshScreenState();
}

class _RefreshScreenState extends State<RefreshScreen> {

  int _page = 1;
  Map<String,dynamic> _pageObj = {'last':0};

  List<String> items = [];

  @override
  void initState() {
    super.initState();

    fetch();

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
        // JSON 문자열 ➡ List<>
        var utf8Decoded = utf8.decode( response.bodyBytes );
        var result = json.decode(utf8Decoded);
        final page = result['page'];
        final List list = result['list'];
        // final List newData = json.decode(utf8Decoded);
        print('page : ');
        print(page);
        _pageObj = page;

        if( list.isEmpty ) return;
        items = list.map<String>((item) {
          final boardNo = item['boardNo'];
          final title = item['title'];
          return 'Item $boardNo - $title';
        }).toList();

        // 다음 페이지
        _page++;
      });
    }

  }


  Future _refresh() async {
    print('fetch...');
    // http 
    // 1. URL 인코딩
    // 2. GET 방식 요청
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    if( response.statusCode == 200 ) {
      setState(() {

        // JSON 문자열 ➡ List<>
        final List newData = json.decode(response.body);

        List<String> newList = newData.map<String>((item) {
          final id = item['id'];
          final title = item['title'];
          return 'Item $id - $title';
        }).toList();

        items = newList;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pull Reload'),),
      body: 
        RefreshIndicator(
          onRefresh: fetch,
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              if( index < items.length ){
                final item = items[index];
                return ListTile(title: Text(item),);
              }
              else {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _page = 1;
                    });
                    fetch();
                  }, 
                  child: const Text('처음으로 돌아가기')
                );
              }
            },
            itemCount: _page > _pageObj['last'] ? items.length+1 : items.length 
          ),
        )

      
      
    );
  }
}