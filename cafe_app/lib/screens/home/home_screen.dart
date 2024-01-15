
import 'package:cafe_app/screens/menu/menu_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/models/coffee.dart';
import 'package:intl/intl.dart';


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭바 메뉴에 들어갈 아이템
    List<String> menuItems = [
      "신메뉴",
      "커피",
      "디카페인",
      "Tea"
    ];


    // 이미지 슬라이드 아이템
    List<String> bannerItemImgUrl = [
      'images/banner01.jpg',
      'images/banner02.jpg',
    ];


    // 커피 메뉴 아이템
    List<String> coffeeMenuImgUrl = [
      'images/coffee01.jpg',
      'images/coffee02.jpg',
      'images/coffee03.jpg',
      'images/coffee04.jpg',
      'images/coffee05.jpg',
      'images/coffee06.jpg',
      'images/coffee01.jpg',
      'images/coffee02.jpg',
      'images/coffee03.jpg',
      'images/coffee04.jpg',
      'images/coffee05.jpg',
      'images/coffee06.jpg',
    ];


    return DefaultTabController(
      initialIndex: 0,            // 탭바 초기 인덱스
      length: menuItems.length,   // 탭바 아이템 개수
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '메뉴',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,  // appbar title 가운데 정렬
          backgroundColor: Colors.white,
          leading: const Icon(
            Icons.home,
            color: Colors.grey,
          ),
          // 탭바 
          bottom: TabBar(
            tabs: List.generate(
              menuItems.length, 
              (index) => Tab(
                text: menuItems[index],
              )
            ),
            unselectedLabelColor: Colors.grey,    // 미선택 라벨 색상
            labelColor: Colors.purple,            // 라벨 색상
            indicatorColor: Colors.purpleAccent,
            indicatorSize: TabBarIndicatorSize.tab, // tab, label
            // isScrollable: true,                     // 스크롤 여부
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // 탭1 : 신메뉴
            ListView(
              children: [
                  // 배너 
                  CarouselSlider.builder(
                    itemCount: bannerItemImgUrl.length, 
                    itemBuilder: (context, index, realIndex) {
                      return Stack(
                        children: [
                          Image.asset(
                            "${bannerItemImgUrl[index]}",
                            fit: BoxFit.cover,
                            // 이미지 가로 사이즈를 앱 가로 사이즈로 지정
                            width: MediaQuery.of(context).size.width,
                          )
                        ],
                      );
                    }, 
                    options: CarouselOptions(
                      viewportFraction: 1.0   // 화면당 이미지 개수 (1개)
                    )
                  ),
                  // 커피 메뉴
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: 
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "조은 카페의 신메뉴",
                              style: TextStyle(color: Colors.purpleAccent),
                            ),
                            GridView.builder(
                              // ✅ physics : 위젯 스크롤 동작을 지정하는 속성
                              // ScrollPhysics          : 기본 스크롤 동작 위젯
                              // BouncingScrollPhysics  : 바운스 효과 스크롤 동작 위젯
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,         // 큰 이미지인 경우 축소해서 적용
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,      // 그리드 컬럼 개수 (3개)
                              ),
                              itemCount: coffeeMenuImgUrl.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                          "${coffeeMenuImgUrl[index]}",
                                          fit: BoxFit.cover,
                                        ),
                                );
                              },
                            )
                          ],
                        ),
                  )
              ],
            ),

            // Center(child: Text('신메뉴 입니다.'),),
            // const Center(child: Text('커피 입니다.')),
            // 커피 메뉴 탭바뷰
            ListView(
              children: 
                  List.generate(
                    // 아이템 개수
                    coffeeList.length,
                    (index) => Container(
                      height: 150.0,
                      child: GestureDetector(
                        // 클릭 시, 상세화면 이동  (다시 작업)
                        onTap: () {
                          // 상세 화면으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => 
                              MenuDetailScreen(item: coffeeList[index])
                            )
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            // 이미지, 내용 영역
                            children: [
                              Image.asset(
                                "${coffeeList[index].imageUrl}",
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 메뉴 이름, 가격
                                    Text(
                                      "${coffeeList[index].title}",
                                      style: TextStyle(fontSize: 22.0),
                                    ),
                                    Text(
                                      "${NumberFormat
                                          .decimalPattern()
                                          .format(coffeeList[index].price) }원",
                                      // "${coffeeList[index].price} 원",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    )
                  )
            ),

            const Center(child: Text('디카페인 입니다.')),
            const Center(child: Text('Tea 입니다.')),
          ],
        ),
      )
    );
  }
}