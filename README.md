# nconsole

A library for show log in console

## Getting Started

![Demo NConsole](./assets/demo_nconsole.png)

## Installation

```sh
flutter pub add nconsole
```

## Usages

```dart
import 'package:nconsole/nconsole.dart';

void main() {
  if (Platform.isAndroid) {
    NConsole.setUri("ip_address");
  }
  NConsole.isEnable = true;

  NConsole.log('Hello, World!');
  NConsole.log("data--->", {
    "name": "alex",
    "old": 12,
  });
}
```

