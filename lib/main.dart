import 'package:flutter/material.dart';
import 'package:lint_helper/ui/pages/home_page.dart';

// TODO на каждом rule повесить бейдж (в виде лампочки не двигающейся - см ниже) core recommended flutter / community (а еще warning/error level цветом выделить)
// TODO внизу bar где фильтрация ALL, CORE, RECOMMENDED, FLUTTER, COMMUNITY, MY , NEW RAW PASTE
// NEW RAW PASTE - скопировать свой yaml

// TODO сделать приложение не зависимым от обновления (all rules / core /recommended/ my/ все уметь скачивать заново и сохранять в pref со значками  new!)

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
      title: 'lint overviewer',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   void _incrementCounter() async {
//     try {
//       print('pressed');
// final t = await RulesParser().fetchAndParse();
// await save(t);
// final tr = await read();

// final fetcher = Fetcher();
// final initOfficialSet = await fetcher.loadInitialOfficialRules();
// final initCommunitySet = await fetcher.loadInitialCommunityRules();
// final leftSet = await fetcher.fetchOfficialRules();
// final rightSet = await fetcher.fetchCommunityRules();
// final comparator = Comparator(leftSet, rightSet);
// comparator.consoleReport('official', 'community');
//     print('complete without error');
//   } catch (e) {
//     print('error $e');
//   }
// }
