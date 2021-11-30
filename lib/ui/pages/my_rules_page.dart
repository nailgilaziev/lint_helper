import 'package:flutter/material.dart';
import 'package:lint_helper/fetchers/rules_from_yaml.dart';

class MyRulesPage extends StatefulWidget {
  const MyRulesPage({Key? key}) : super(key: key);

  @override
  _MyRulesPageState createState() => _MyRulesPageState();
}

class _MyRulesPageState extends State<MyRulesPage> {
  late final controller = TextEditingController();

  void parseAndReplace() {
    try {
      final yaml = YamlRules();
      final body = controller.text;
      final cut = yaml.cutRulesFromYaml(body);
      final s = yaml.rulesSourceToSet(cut);
      if (s.isEmpty) {
        dialogParsingNoItems();
      }
    } catch (e, st) {
      print(st);
    }
  }

  void save() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your rules'),
        actions: [
          TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  parseAndReplace();
                } else {
                  dialogClearing();
                }
              },
              child:
                  const Text('APPLY', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          maxLines: null,
          expands: true,
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'paste here whole yaml content or rules list',
          ),
        ),
      ),
    );
  }

  void dialogClearing() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text(
            'This will delete previously saved rules (if they exist).'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                parseAndReplace();
              },
              child: const Text('Yes, clear it')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void dialogParsingNoItems() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('No items parsed'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                save();
              },
              child: const Text('Ok, continue')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }
}
