import 'package:flutter/material.dart';

enum LintSource { core, recommended, flutter, community, nail, my }

Color colorForLintSource(LintSource source) {
  switch (source) {
    case LintSource.core:
      return Colors.lightBlueAccent;
    case LintSource.recommended:
      return Colors.blue;
    case LintSource.flutter:
      return Colors.blueAccent;
    case LintSource.community:
      return Colors.indigoAccent;
    case LintSource.nail:
      return Colors.green;
    case LintSource.my:
      return Colors.lightGreen;
  }
}

IconData iconForLintSource(LintSource? source) {
  if (source == null) {
    return Icons.all_inclusive;
  }
  switch (source) {
    case LintSource.core:
      return Icons.dashboard_rounded;
    case LintSource.recommended:
      return Icons.recommend;
    case LintSource.flutter:
      return Icons.flutter_dash;
    case LintSource.community:
      return Icons.people;
    case LintSource.nail:
      return Icons.person;
    case LintSource.my:
      return Icons.text_snippet_outlined;
  }
}

String urlForSource(LintSource source) {
  switch (source) {
    case LintSource.core:
      return 'https://raw.githubusercontent.com/dart-lang/lints/main/lib/core.yaml';
    case LintSource.recommended:
      return 'https://raw.githubusercontent.com/dart-lang/lints/main/lib/recommended.yaml';
    case LintSource.flutter:
      return 'https://raw.githubusercontent.com/flutter/packages/master/packages/flutter_lints/lib/flutter.yaml';
    case LintSource.community:
      return 'https://raw.githubusercontent.com/passsy/dart-lint/master/lib/analysis_options.yaml';
    case LintSource.nail:
      return '';
    case LintSource.my:
      throw 'Incorrect usage: url for LintSource.my can not exist';
  }
}
