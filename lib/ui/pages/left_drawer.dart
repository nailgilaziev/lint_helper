import 'package:flutter/material.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/ui/pages/compare.dart';
import 'package:lint_helper/ui/pages/my_rules_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer(
      {Key? key, required this.data, required this.refreshDataFunc})
      : super(key: key);

  final AllData data;
  final Future<void> Function() refreshDataFunc;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
                  child: Text('Lint rules overviewer helper app',
                      style: Theme.of(context).textTheme.caption))),
          ListTile(
            title: const Text('Compare rules'),
            leading: const Icon(Icons.compare),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return ComparePage(data: data);
              }));
            },
          ),
          ListTile(
            title: const Text('Add my rules'),
            leading: const Icon(Icons.text_snippet_outlined),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const MyRulesPage();
              }));
            },
          ),
          ListTile(
            title: const Text('Refresh data'),
            leading: const Icon(Icons.replay_circle_filled),
            onTap: () {
              Navigator.pop(context);
              refreshDataFunc();
            },
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('sync date:\n'),
              Text(data.syncDate.toString()),
            ],
          ))
        ],
      ),
    );
  }
}
