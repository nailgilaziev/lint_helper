import 'package:lint_helper/helpers.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/models/lint_source.dart';

enum Section { analyzerLanguage, lintError, lintStyle, lintPub }

Section getSectionFromString(String s) {
  for (final element in Section.values) {
    if (element.toString() == s) {
      return element;
    }
  }
  throw 'getSectionFromString can\'t find enum value for string "$s"';
}

Section getSectionFromInt(int i) {
  if (i < 0 || i > Section.values.length) {
    throw 'getSectionFromInt can\'t find enum value for index $i';
  }
  return Section.values[i];
}

class Item {
  String name;
  String desc;
  Section section;
  List<int>? _indexes;

  List<int>? get indexes => _indexes;
  int rank = 0;

  String urlTemplate = lintRulePageTemplate;

  Set<LintSource> owners = {};

  Item(
      {required this.name,
      required this.desc,
      required this.section,
      String urlTemplate = ''}) {
    if (urlTemplate.isNotEmpty) {
      this.urlTemplate = urlTemplate;
    }
    resetIndexes();
  }

  Item.fromJson(
    Map<String, dynamic> json,
  )   : name = json['name'] as String,
        desc = json['desc'] as String,
        section = getSectionFromInt(json['sect'] as int) {
    resetIndexes();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'desc': desc,
        'sect': section.index,
      };

  void resetIndexes() {
    _indexes = [];
    // TODO fix it or figure out something new
    // rank = kCommunityRulesForRanking.indexOf(name);
  }

  void match(String queryString) {
    var query = queryString.replaceAll(' ', '');

    // print('text = $name');
    // print('query = $queryString');
    // print('');
    List<List<int>>? positions;
    if (queryString.contains(' ')) {
      //strong mode? пробел наверное использовался осмысленно? и посимвольно искать не нужно уже. требуется поиск по словам?
      final words = queryString.split(' ');
      positions = [];
      for (final word in words) {
        final start = name.indexOf(word);
        if (start == -1) {
          positions = null;
          break;
        }
        positions!.add(List.generate(word.length, (index) => start + index));
      }
    } else {
      positions = positionsForEachSymbol(query);
    }
    // print('positions=$positions');
    if (positions == null) {
      _indexes = null;
      return;
    }
    var allIndexes = <int>{};
    for (final inner in positions) {
      allIndexes.addAll(inner);
    }
    _indexes = allIndexes.toList();
    indexes!.sort();

    rank = calculateMaxContinuousWordLength();
    rank += additionalRankForFirstLetters();
    // print('indexes:$indexes');
  }

  int calculateMaxContinuousWordLength() {
    int max = 0;
    int curLength = 0;
    int pv = _indexes!.first;
    for (final v in _indexes!) {
      if (pv + 1 == v) {
        curLength++;
      } else {
        if (curLength > max) {
          max = curLength;
        }
        curLength = 0;
      }
      pv = v;
    }
    if (curLength > max) {
      max = curLength;
    }
    return max;
  }

  int additionalRankForFirstLetters() {
    int score = 0;
    for (final index in indexes!) {
      if (index == 0) {
        score += 1;
      } else {
        if (name[index - 1] == '_' || name[index - 1] == ' ') {
          score++;
        }
      }
    }
    return score;
  }

  List<List<int>>? positionsForEachSymbol(String query) {
    final positions =
        List.generate(query.length, (i) => name.allIndexes(query[i]));
    // print(positions);
    var minimalIndex = -1;
    for (final inner in positions) {
      inner.cutLowerThan(minimalIndex + 1);
      if (inner.isEmpty) return null;
      minimalIndex = inner.first;
    }
    var maximalIndex = name.length;
    for (final inner in positions.reversed) {
      inner.cutUpperThan(maximalIndex);
      if (inner.isEmpty) return null;
      maximalIndex = inner.last;
    }
    return positions;
  }
}
