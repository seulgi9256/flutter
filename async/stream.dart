
Stream<int> countStream(int to) async* {
  for(int i = 1 ; i <= to ; i++ ){
    await Future.delayed(Duration(seconds: 1), () {
      print('요청 : $i');
    });
    yield i;
  }
}

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  print('합계');
  await for(final value in stream ) {
    sum += value;
    print('전달된 값 : $value - sum : $sum');
  }
  return sum;
}


Future<void> main(List<String> args) async {
  var stream = countStream(10);
  var sum = await sumStream(stream);
  print('요청중...');
  print(sum);
  print(stream);
}