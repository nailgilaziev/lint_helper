import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lint_helper/comparator.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:lint_helper/ui/pieces/items_list_view.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({Key? key, required this.data}) : super(key: key);

  final AllData data;

  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final leftSource = ValueNotifier(LintSource.flutter);
  final rightSource = ValueNotifier(LintSource.community);

  @override
  void initState() {
    leftSource.addListener(sourceChanged);
    rightSource.addListener(sourceChanged);
    sourceChanged();
    super.initState();
  }

  late Comparator comparator;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'only in left'),
    Tab(text: 'exist in both'),
    Tab(text: 'only in right'),
  ];

  void sourceChanged() {
    final leftSet = Set<Item>.from(widget.data.included[leftSource.value]!);
    final rightSet = Set<Item>.from(widget.data.included[rightSource.value]!);
    comparator = Comparator(leftSet, rightSet);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;
    final threeList = [
      ItemsListView(items: comparator.leftSet.toList()),
      ItemsListView(items: comparator.middleSet.toList()),
      ItemsListView(items: comparator.rightSet.toList()),
    ];
    final body = wide
        ? Row(children: threeList.map((e) => Expanded(child: e)).toList())
        : TabBarView(
            children: threeList,
          );
    final scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDropDown(leftSource),
            const Text('vs', textScaleFactor: 0.6),
            buildDropDown(rightSource),
          ],
        ),
        bottom: TabBar(
          tabs: myTabs,
        ),
      ),
      body: body,
    );
    return DefaultTabController(
      length: myTabs.length,
      child: scaffold,
    );

    // wide
    //     ? Row(
    //         children: [
    //           Expanded(
    //             child: Column(
    //               children: buildPanel(leftSource),
    //             ),
    //           ),
    //           Container(
    //             color: Colors.black26,
    //             width: 1,
    //           ),
    //           Expanded(
    //             child: Column(
    //               children: buildPanel(rightSource),
    //             ),
    //           )
    //         ],
    //       )
    //     :
    //     Column(
    //   crossAxisAlignment: CrossAxisAlignment.stretch,
    //   children: [
    //     buildDropDown(leftSource),
    //     Expanded(
    //       child: ItemsListView(items: comparator.leftSet.toList()),
    //     ),
    //     buildDropDown(rightSource),
    //     Expanded(
    //       child: ItemsListView(items: comparator.rightSet.toList()),
    //     ),
    //   ],
    // ),
  }

  Widget buildDropDown(ValueNotifier<LintSource> source) {
    return Container(
      constraints: BoxConstraints(maxHeight: 32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<LintSource>(
        value: source.value,
        isExpanded: false,
        icon: const Icon(Icons.arrow_downward),
        underline: Container(width: 0, height: 0),
        dropdownColor: Colors.indigo,
        iconSize: 12,
        iconEnabledColor: Colors.white,
        onChanged: (LintSource? newValue) {
          setState(() {
            source.value = newValue!;
          });
        },
        items: LintSource.values
            .map<DropdownMenuItem<LintSource>>((LintSource source) {
          return DropdownMenuItem<LintSource>(
            value: source,
            child: Text(
              source.toString().substring(11),
              textScaleFactor: 0.8,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }
}
