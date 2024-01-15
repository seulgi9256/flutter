class Coffee {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String imageUrl2;

  Coffee({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.imageUrl2,
  });

} // class Coffee


// 샘플 데이터
List<Coffee> coffeeList = [
  Coffee(
    id: "01", 
    title: "아메리카노", 
    price: 2000, 
    imageUrl: "images/coffee01.jpg", 
    imageUrl2: "images/coffee02.jpg"
  ),
  Coffee(
    id: "02", 
    title: "카페라떼", 
    price: 3500, 
    imageUrl: "images/coffee02.jpg", 
    imageUrl2: "images/coffee02.jpg"
  ),
  Coffee(
    id: "03", 
    title: "리스트레토라떼", 
    price: 4000, 
    imageUrl: "images/coffee03.jpg", 
    imageUrl2: "images/coffee03.jpg"
  ),
  Coffee(
    id: "04", 
    title: "바닐라라떼", 
    price: 4000, 
    imageUrl: "images/coffee04.jpg", 
    imageUrl2: "images/coffee04.jpg"
  ),
  Coffee(
    id: "05", 
    title: "청포도스파클링", 
    price: 5500, 
    imageUrl: "images/coffee05.jpg", 
    imageUrl2: "images/coffee05.jpg"
  ),
];
