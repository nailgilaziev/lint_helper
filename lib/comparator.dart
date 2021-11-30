class Comparator {
  final Set<String> leftSet;
  final Set<String> rightSet;
  final Set<String> middleSet = {};

  Comparator(this.leftSet, this.rightSet) {
    final oneOfSets = Set.from(leftSet);
    for (final one in oneOfSets) {
      if (rightSet.contains(one)) {
        leftSet.remove(one);
        rightSet.remove(one);
        middleSet.add(one);
      }
    }
  }

  void consoleReport(String leftName, String rightName) {
    report(leftName, leftSet);
    report(rightName, rightSet);
    report('both', middleSet);
  }

  void report(String sourceName, Set<String> rules) {
    print('');
    print('');
    print('$sourceName declare additionally next rules:');
    for (final rule in rules) {
      print('$rule - https://dart-lang.github.io/linter/lints/$rule.html');
    }
  }
}
