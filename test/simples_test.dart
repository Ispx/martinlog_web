import 'package:martinlog_web/dependencie_injection_manager/simple.dart';

void main() {
  final simple = Simple();
  simple.add<MockTest1>(() => MockTest1("PRIMEIRA INSTANCIA DE MOCKTEST"),
      isSingleton: true);
  //simple.add<MockTest>(() => MockTest("SEGUNDA INSTANCIA DE MOCKTEST"));
  //print(simple.get<MockTest>().toString());
  final instalce = simple.get<MockTest1>();
  print(instalce.toString());

  print(instalce.toString());

  instalce.value = "VALOR ALTERADO INSTANCIA DE MOCKTEST";
  simple.update<MockTest1>(
    () => instalce,
  );

  print(simple.get<MockTest1>().toString());

  simple.clear();
  print(simple.get<MockTest1>().toString());

  // print(simple.get<MockTest>().toString());
}

class MockTest {
  String value;
  MockTest(this.value);

  @override
  String toString() {
    return value;
  }
}

class MockTest1 {
  String value;
  MockTest1(this.value);

  @override
  String toString() {
    return value;
  }
}
