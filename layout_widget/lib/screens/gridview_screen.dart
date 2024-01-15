import 'package:flutter/material.dart';
import 'package:layout_widget/models/animal.dart';

class GridViewScreen extends StatefulWidget {
  final List<Animal> list;
  const GridViewScreen({super.key, required this.list});

  @override
  State<GridViewScreen> createState() => _GridViewScreenState();
}

class _GridViewScreenState extends State<GridViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그리드 뷰', )
      ),
      body: Container(
        child: Center(
          child: 
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,        // 열 개수
                crossAxisSpacing: 10.0,   // 열 간격
                mainAxisSpacing: 10.0,    // 행 간격
              ),
              itemBuilder: (context, position) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  color: Colors.grey,
                  child: Column(
                    children: [
                      Image.asset(
                        // 'image/animal1.png',
                        widget.list[position].imagePath ?? 'image/product.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        // '고양이',
                        widget.list[position].animalName ?? '이름 없음',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 5,),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.list.removeAt(position);
                          });
                        }, 
                        child: const Text('삭제하기')
                      )
                    ],),
                );
              },
              itemCount: widget.list.length,
            )

            // GridView(
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //   crossAxisCount: 2,        // 열 개수
              //   crossAxisSpacing: 10.0,   // 열 간격
              //   mainAxisSpacing: 10.0,    // 행 간격
              // ),
            //   children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                //   color: Colors.grey,
                //   child: Column(
                //     children: [
                //       Image.asset(
                //         'image/animal1.png',
                //         width: 80,
                //         height: 80,
                //         fit: BoxFit.contain,
                //       ),
                //       const SizedBox(height: 10,),
                //       const Text(
                //         '고양이',
                //         style: TextStyle(fontSize: 20),
                //       ),
                //       const SizedBox(height: 5,),
                //       ElevatedButton(
                //         onPressed: () {
                          
                //         }, 
                //         child: const Text('삭제하기')
                //       )
                //     ],),
                // ),
            //   ],
            // ),
        ),
      ),
    );
  }
}