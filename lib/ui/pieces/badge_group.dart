import 'package:flutter/material.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:lint_helper/ui/pieces/badge_indicator.dart';

class BadgeGroup extends StatelessWidget {
  const BadgeGroup(this.item, {Key? key}) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      // height: 64,
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        // direction: Axis.vertical,
        children: [
          for (final source in LintSource.values)
            BadgeIndicator(
              source.toString().substring(11).toUpperCase(),
              active: item.owners.contains(source),
              activeColor: colorForLintSource(source),
            )
        ],
      ),
    );
  }
}
