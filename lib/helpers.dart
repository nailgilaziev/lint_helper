extension AllIndexes on String {
  List<int> allIndexes(String symbol) {
    List<int> all = [];
    var foundIndex = -1;
    for (var i = 0; i < length; i++) {
      foundIndex = indexOf(symbol, foundIndex + 1);
      if (foundIndex == -1) {
        break;
      }
      all.add(foundIndex);
    }
    return all;
  }
}

extension OperationsForSortedList on List<int> {
  void cutLowerThan(int min) {
    while (length > 0 && first < min) {
      removeAt(0);
    }
  }

  void cutUpperThan(int max) {
    while (length > 0 && last > max) {
      removeLast();
    }
  }
}
