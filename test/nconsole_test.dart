import 'package:flutter_test/flutter_test.dart';
import 'package:nconsole/nconsole.dart';

class TestModel {
  final String name;
  final int old;

  TestModel(this.name, this.old);
}

void main() {
  NConsole.setUri("localhost");
  NConsole.isEnable = true;

  final testModel = TestModel("alex", 12);

  test("NConsole.log", () async {
    NConsole.log(
      testModel,
      "data",
      {
        "name": "alex",
        "old": 12,
        "hello": "world",
      },
    );

    await Future.delayed(const Duration(seconds: 2));
  });

  test("Send big data", () async {
    final data = List.generate(10000, (index) => "index: $index");
    NConsole.log("data", data);

    await Future.delayed(const Duration(seconds: 3));
  });
}
