# nconsole

A library for show log in console

## Getting Started

![Demo NConsole](https://github.com/nghinv-software/nconsole-flutter/blob/main/assets/demo_nconsole.png)

## Installation

App desktop download [NConsole](https://drive.google.com/drive/folders/1P4cqXhalzsiPtrVAKWvoD9tK_pt9ZpzJ?usp=share_link)

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

