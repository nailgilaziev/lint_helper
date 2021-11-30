import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:lint_helper/ui/pieces/items_list_view.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({Key? key, required this.data}) : super(key: key);

  final AllData data;

  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Diff'),
      ),
      body: wide
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    children: buildPanel(leftSource),
                  ),
                ),
                Container(
                  color: Colors.black26,
                  width: 1,
                ),
                Expanded(
                  child: Column(
                    children: buildPanel(rightSource),
                  ),
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...buildPanel(leftSource),
                ...buildPanel(rightSource),
              ],
            ),
    );
  }

  List<Widget> buildPanel(ValueNotifier<LintSource> source) {
    return [
      buildDropDown(source),
      Expanded(
        child: ItemsListView(items: widget.data.included[source.value]!),
      ),
    ];
  }

  final leftSource = ValueNotifier(LintSource.flutter);
  final rightSource = ValueNotifier(LintSource.community);

  Widget buildDropDown(ValueNotifier<LintSource> source) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: DropdownButton<LintSource>(
          value: source.value,
          icon: const Icon(Icons.arrow_downward),
          underline: null,
          iconSize: 12,
          onChanged: (LintSource? newValue) {
            setState(() {
              source.value = newValue!;
            });
          },
          items: LintSource.values
              .map<DropdownMenuItem<LintSource>>((LintSource source) {
            return DropdownMenuItem<LintSource>(
              value: source,
              child: Text(source.toString().substring(11)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
