import 'package:flutter/material.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/ui/pieces/badge_group.dart';
import 'package:url_launcher/url_launcher.dart';

class LintRuleItem extends StatelessWidget {
  const LintRuleItem(this.item, {Key? key}) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: RichText(
        text: TextSpan(
          children: buildTextSpansForItem(item),
          style: DefaultTextStyle.of(context).style,
        ),
      ),
      subtitle: Row(
        children: [
          // Text(item.indexes.toString()),
          // const SizedBox(width: 16),
          // Text(item.rank.toString()),
          // const SizedBox(width: 16),
          Expanded(
              child: Text(
            item.desc,
            maxLines: 1,
          )),
        ],
      ),
      trailing: BadgeGroup(item),
      dense: true,
      onTap: () {
        _launchURL(item.name);
      },
    );
  }

  List<TextSpan> buildTextSpansForItem(Item item) {
    List<TextSpan> spans = [];
    int i = 0;

    /// так как items мы забираем из общего источника, то в нем .indexes уже заполнены согласно поисковой строке
    /// .indexes == null - это состояние, когда элемент не соответствует поисковой строке, но его все равно нужно отрисовать
    if (item.indexes != null) {
      for (final v in item.indexes!) {
        if (v - i > 0) {
          spans.add(TextSpan(text: item.name.substring(i, v)));
        }
        spans.add(TextSpan(
            text: item.name.substring(v, v + 1),
            style: const TextStyle(fontWeight: FontWeight.bold)));
        i = v + 1;
      }
    }
    if (item.name.length - i > 0) {
      spans.add(TextSpan(text: item.name.substring(i)));
    }
    return spans;
  }

  void _launchURL(String rule) async {
    String url = 'https://dart-lang.github.io/linter/lints/$rule.html';
    await canLaunch(url) ? await launch(url) : print('Could not launch $url');
  }
}
