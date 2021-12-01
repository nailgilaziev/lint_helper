import 'package:http/http.dart' as http;
import 'package:lint_helper/models/lint_source.dart';

const kLinePrefix = '    ';
const kCommentPrefix = '    #';

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
    if (start == -1) return body;
    final source = body.substring(start + 9);
    return source;
  }

  Set<String> rulesSourceToSet(String rulesSource) {
    final s = rulesSource
        .split('\n')
        .map((e) {
          var line = e;
          if (line.contains('#')) {
            final commentStart = line.indexOf('#');
            line = line.substring(0, commentStart);
          }
          if (line.contains(':')) {
            final semicolonStart = line.indexOf(':');
            line = line.substring(0, semicolonStart);
          }
          line = line.trim();
          if (line.startsWith('- ')) {
            line = line.substring(2);
          }
          return line;
        })
        .where((element) => element.isNotEmpty)
        .toSet();
    print('rules (maybe rules) founded: ${s.length}');
    return s;
  }
}
