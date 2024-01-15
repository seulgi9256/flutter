import 'package:flutter/material.dart';
import 'package:layout_widget/models/animal.dart';

class ListViewScreen extends StatefulWidget {
  final List<Animal> list;
  const ListViewScreen({super.key, required this.list}); 

  @override
  State createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리스트 뷰')),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
        child: Center(
          child: ListView.builder(
            itemBuilder: (context, position) {
              return GestureDetector(
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        // ''image/animal1.jpg'
                        widget.list[position].imagePath ?? 'image/product.jpg',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      Text(widget.list[position].animalName ?? '이름없음'),
                      const Icon(
                        Icons.arrow_right,
                        size: 32.0,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  print('카드 클릭!!!');
                  AlertDialog dialog = AlertDialog(
                    content: Text(
                      '이 동물은 ${widget.list[position].kind} 입니다',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('확인'),
                      )
                    ],
                  );
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog,
                  );
                },
                onLongPress: () {
                  print('position ${position}');
                  setState(() {
                    widget.list.removeAt(position);
                  });
                },
              );
            },
            itemCount: widget.list.length,
          ),
        ),
      ),
    );
  }
}
