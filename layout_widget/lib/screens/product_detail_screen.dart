
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품 상세화면'),),
      body: Container(
        margin: const EdgeInsets.all(12.0),
        // color: Colors.lightBlue,
        child: Column(
                // 주축 정렬 방식
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상품 이미지
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('image/product.jpg'),
                        fit: BoxFit.cover
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  const SizedBox(height: 12.0,),
                  // 상품 이름
                  const Text(
                    '상품 이름',
                    style: TextStyle(
                            fontSize: 22.0, 
                            fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 10.0,),
                  // 상품 정보
                  const Text(
                    '파스타와 각종 식재료 입니다.',
                    style: TextStyle(
                            fontSize: 16.0, 
                            fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 10.0,),
                  // 상품 가격
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Icon(
                            Icons.payment,
                            size: 24.0,
                            color: Colors.black,
                          ),
                          Text(
                                  '50,000원',
                                  style: TextStyle(
                                          fontSize: 18.0, 
                                          fontWeight: FontWeight.bold,
                                          ),
                          ),
                      ],
                    )
                  ),
                  // 장바구니 추가 버튼
                  Container(
                    // 가로 전체 사이즈 
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                            onPressed: () {

                            },
                            style: 
                              ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white
                              ),
                            child: const Text('장바구니 추가'),
                          ),
                  ),
                  const Divider(),



                  
                ]
        )
      ),
    );
  }
}