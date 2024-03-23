import 'dart:io';

import 'package:flutter/material.dart';

import 'package:nconsole/nconsole.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              if (Platform.isAndroid) {
                NConsole.setUri("10.10.50.16");
              }
              NConsole.isEnable = true;

              NConsole.log('Hello, World!');
              NConsole.log("data--->", {
                "name": "alex",
                "old": 12,
              });
            },
            child: const Text('Send log to [Server Log] app'),
          ),
        ),
      ),
    );
  }
}
