import 'package:http/http.dart' as http;
import 'package:lint_helper/models/lint_source.dart';

const kPrefix = '    ';

class YamlRules {
  Future<Set<String>> fetchRules(LintSource source) async {
    var url = urlForSource(source);
    final rawRules = await _fetchRulesFromRemoteYaml(url);
    return rulesSourceToSet(rawRules);
  }

  Future<String> _fetchRulesFromRemoteYaml(String url) {
    print('-> GET $url');
    return http
        .get(Uri.parse(url))
        .then((response) => cutRulesFromYaml(response.body))
        .onError((e, st) {
      print('error happens for url = $url\n$e');
      throw e!;
    });
  }

  String cutRulesFromYaml(String body) {
    if (body.length < 9) return body;
    int start = body.indexOf('  rules:');
    final source = body.substring(start + 9);
    return source;
  }

  Set<String> rulesSourceToSet(String rulesSource) {
    final s = rulesSource
        .split('\n')
        .where((line) => line.startsWith(kPrefix))
        .map((line) {
      if (line.contains(':')) {
        final t = line.indexOf(':');
        return line.trim().substring(0, t);
      }
      return line.substring(kPrefix.length + 2);
    }).toSet();
    print('rules (maybe rules) founded: ${s.length}');
    return s;
  }
}
