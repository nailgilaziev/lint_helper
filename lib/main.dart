import 'package:flutter/material.dart';
import 'package:lint_helper/ui/pages/home_page.dart';

// TODO на каждом rule повесить бейдж warning/error level цветом выделить
// TODO all rules / core /recommended/ my/ все уметь скачивать заново и сохранять в pref со значками  new!)

class Calc {
  int sum(int a, int b) {
    return a + b;
  }
}

void main() {
  print('main called');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lint helper',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}
