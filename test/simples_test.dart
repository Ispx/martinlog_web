import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';

void main() {
  final simple = Simple();

  simple.startUp((i) {
    i.addSingleton<MockTest1>(
      () => MockTest1("PRIMEIRA INSTANCIA DE MOCKTEST"),
    );
    i.addFactory<MockTest>(() => MockTest("SEGUNDA INSTANCIA DE MOCKTEST"));

    return i;
  });

  MockTest mockTestInstance = simple.get<MockTest>();
  print(mockTestInstance.toString());
  print(simple.get<MockTest>().toString());
  final instalce = simple.get<MockTest1>();
  print(instalce.toString());

  instalce.value = "VALOR ALTERADO INSTANCIA DE MOCKTEST";
  simple.update<MockTest1>(
    () => instalce,
  );
  print(simple.get<MockTest1>().toString());
  simple.reset();
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
