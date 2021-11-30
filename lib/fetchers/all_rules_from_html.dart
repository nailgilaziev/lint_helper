import 'package:http/http.dart' as http;
import 'package:lint_helper/models/item.dart';

class AllRulesFetcher {
  static const url = 'https://dart-lang.github.io/linter/lints/index.html';

  late String html;

  Future<String> _fetchHtml() async {
    print('making request...');
    final r = await http.get(Uri.parse(url));
    var msg = 'status code for parsing rules ${r.statusCode}';
    if (r.statusCode != 200) throw msg;
    return r.body;
  }

  Future<Set<Item>> fetchAndParse() async {
    html = await _fetchHtml();

    const err = '<h2>Error Rules</h2>';
    const style = '<h2>Style Rules</h2>';
    const pub = '<h2>Pub Rules</h2>';

    return (extractItems(err, style, Section.lintError) +
            extractItems(style, pub, Section.lintStyle) +
            extractItems(pub, '</body>', Section.lintPub))
        .toSet();
  }

  List<Item> extractItems(String from, String to, Section section) {
    const searchPattern = '<strong><a href = "';
    final start = html.indexOf(from);
    final end = html.indexOf(to);
    return html.substring(start, end).split('\n').where((line) {
      return line.contains(searchPattern);
    }).map((line) {
      final nStart = line.indexOf(searchPattern) + searchPattern.length;
      final nEnd = line.indexOf('.', nStart);
      final name = line.substring(nStart, nEnd);
      final dStart = line.indexOf('<p>') + 3;
      final dEnd = line.indexOf('</p>', dStart);
      final desc = line.substring(dStart, dEnd);
      return Item(name: name, desc: _removeAllHtmlTags(desc), section: section);
    }).toList();
  }

  static String _removeAllHtmlTags(String htmlText) {
    var exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }
}
