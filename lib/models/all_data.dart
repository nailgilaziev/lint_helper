import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kReplacement = '{***}';

const lintRulePageTemplate =
    'https://dart-lang.github.io/linter/lints/$kReplacement.html';

class AllData extends ChangeNotifier {
  DateTime? syncDate;
  Set<Item> all = {};
  Map<LintSource, Set<Item>> included = {};

  void notifyMyItemsAdded() {
    notifyListeners();
  }

  Future<bool> fillFromDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final syncDateMs = prefs.getInt('sync_date');
    if (syncDateMs == null) {
      print('syncDateMs in prefs is null');
      return false;
    }
    syncDate = DateTime.fromMillisecondsSinceEpoch(syncDateMs);
    all = await _readItems();
    print('read from db all rules: ${all.length}');
    for (final source in LintSource.values) {
      final items = prefs.getStringList(source.toString());
      if (items == null) {
        print('error: no lints for source $source');
        return false;
      }
      print('read from db rules: ${items.length} for $source');
      fillItemsForSource(source, items);
    }
    return true;
  }

  Future<bool> saveToDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    syncDate = DateTime.now();
    final savedVals = <bool>[
      await prefs.setInt('sync_date', syncDate!.millisecondsSinceEpoch),
      await saveItems(all),
      for (final source in LintSource.values)
        await saveLintsForSource(
            source, included[source]?.map((e) => e.name).toList() ?? [])
    ];
    print('saving results : $savedVals');
    return savedVals.every((element) => element == true);
  }

  int fillItemsForSource(LintSource source, Iterable<String> names) {
    var items = all.where((e) {
      return names.contains(e.name);
    }).toSet();
    for (var item in items) {
      item.owners.add(source);
    }
    print('added ${items.length} to included for $source');
    included[source] = items;
    return items.length;
  }

  Future<bool> saveItems(Set<Item> allRules) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final readyToSerialize = allRules.map((r) => r.toJson()).toList();
    print('saving all:${allRules.length}');
    final jsonString = jsonEncode(readyToSerialize);
    return await prefs.setString('all_lint_rules', jsonString);
  }

  Future<Set<Item>> _readItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('all_lint_rules');
    if (jsonString == null) return {};
    final arr = jsonDecode(jsonString) as List<dynamic>;
    final deserialized =
        arr.map((v) => Item.fromJson(v as Map<String, dynamic>)).toSet();
    return deserialized;
  }

  Future<bool> saveLintsForSource(
      LintSource source, Iterable<String> names) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('saving rules:${names.length} for $source');
    return prefs.setStringList(source.toString(), names.toList());
  }

  List<Item> genSpecificItems() {
    const analyzerTemplate =
        'https://github.com/dart-lang/language/blob/master/resources/type-system/$kReplacement.md';
    return [
      Item(
          name: 'strict-raw-types',
          desc:
              'List a = [1, 2, 3]; Dart inference here do inference as List<dynamic> a;"',
          section: Section.analyzerLanguage,
          urlTemplate: analyzerTemplate),
      Item(
          name: 'strict-inference',
          desc:
              'Where inference "falls back" to dynamic (or the type\'s bound), inference is considered to have failed',
          section: Section.analyzerLanguage,
          urlTemplate: analyzerTemplate),
      Item(
          name: 'strong-mode',
          desc: 'Strong mode applies a more restrictive type system to Dart',
          section: Section.analyzerLanguage,
          urlTemplate:
              'https://www.google.com/search?q=dart+%22strong-mode%22'),
      Item(
          name: 'strong-mode: implicit-casts',
          desc:
              'A value of false ensures that the type inference engine never implicitly casts from dynamic to a more specific type',
          section: Section.analyzerLanguage,
          urlTemplate:
              'https://dart.dev/guides/language/analysis-options#enabling-additional-type-checks'),
      Item(
          name: 'strong-mode: implicit-dynamic',
          desc:
              'A value of false ensures that the type inference engine never chooses the dynamic type when it can’t determine a static type.',
          section: Section.analyzerLanguage,
          urlTemplate:
              'https://dart.dev/guides/language/analysis-options#enabling-additional-type-checks'),
    ];
  }
}
