import 'package:flutter/material.dart';
import 'package:layout_widget/models/animal.dart';
import 'package:layout_widget/screens/gridview_screen.dart';
import 'package:layout_widget/screens/listview_screen.dart';

void main() {
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: 
//             // const ProductDetailScreen()
//             const ListViewScreen()
//     );
//   }
// }


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // state
  // List<Animal> animalList = List.empty(growable: true);
  List<Animal> animalList = [];

  @override
  void initState() {

    super.initState();

    animalList.add( Animal(
                      imagePath: 'image/animal1.png',
                      animalName: '고양이',
                      kind: '포유류',
                    ) );
    animalList.add( Animal(
                      imagePath: 'image/animal2.png',
                      animalName: '라쿤',
                      kind: '포유류',
                    ) );
    animalList.add( Animal(
                      imagePath: 'image/animal3.png',
                      animalName: '늑대',
                      kind: '포유류',
                    ) );
    animalList.add( Animal(
                      imagePath: 'image/animal4.png',
                      animalName: '코끼리',
                      kind: '포유류',
                    ) );
    animalList.add( Animal(
                      imagePath: 'image/animal5.png',
                      animalName: '벌',
                      kind: '곤충',
                    ) );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '리스트 뷰',
      home: 
          // ListViewScreen(list: animalList),
          GridViewScreen(list: animalList)

    );
  }
}