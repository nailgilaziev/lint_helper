import 'package:flutter/material.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/ui/items/lint_rule_item.dart';

class ItemsListView extends StatelessWidget {
  const ItemsListView({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return Center(
          child: Icon(
        Icons.article,
        color: Colors.indigo,
        size: 48,
      ));
    return ListView.builder(
      itemBuilder: (BuildContext context, int i) => LintRuleItem(items[i]),
      itemCount: items.length,
    );
  }
}
