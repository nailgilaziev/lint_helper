import 'package:flutter/material.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/models/item.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:lint_helper/ui/pages/fetching_page.dart';
import 'package:lint_helper/ui/pages/left_drawer.dart';
import 'package:lint_helper/ui/pieces/items_list_view.dart';

//TODO запоминать выбранный фильтр или всегда открывать на my если он заполнен
class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.dataToShow}) : super(key: key);

  final AllData? dataToShow;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var bootstrapped = false;
  AllData? data;
  late TextEditingController searchController;

  @override
  void initState() {
    searchController = TextEditingController();
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void init() async {
    if (widget.dataToShow != null) {
      useData(widget.dataToShow!);
      return;
    } else {
      final d = AllData();
      if (await d.fillFromDb()) {
        useData(d);
      } else {
        openFetchingPage();
      }
    }
    setState(() {
      print('setState bootstrapped');
      bootstrapped = true;
    });
  }

  void useData(AllData data) {
    setState(() {
      print('setState useData');
      this.data = data;
      refreshItems();
    });
  }

  Future<void> openFetchingPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute<AllData>(
            builder: (BuildContext context) => FetchingPage(data: data)));
    if (result != null) {
      setState(() {
        print('setState openFetchingPage()');
        print('saving result from fetching page');
        useData(result);
      });
    } else {
      print('no result from fetching page');
    }
  }

  List<Item> itemsForIndex(int index) {
    if (data == null) {
      print('no data for itemsForIndex func');
      return [];
    }
    if (index == insertIndexForAll) {
      return data!.all;
    }
    int compensatedIndex = index < insertIndexForAll ? index : index - 1;
    final items = data?.included[LintSource.values[compensatedIndex]] ??
        []; //FIXME тут недоработка, null никогда не будет
    if (items == null) {
      throw 'itemsForIndex returned null for index compensatedIndex $compensatedIndex';
    }
    return items;
  }

  int _selectedIndex = 3;

  String _query = '';

  List<Item> allItems = [];

  String get query => _query;

  set query(String query) {
    _query = query;
    setState(() {
      print('setState query');
      if (query.isEmpty) {
        for (final item in data!.all) {
          item.resetIndexes();
        }
      } else {
        for (final item in allItems) {
          item.match(query);
        }
      }
      refreshItems();
    });
  }

  List<Item> items = [];

  void refreshItems() {
    print('.refreshItems() called');
    allItems = itemsForIndex(_selectedIndex);
    print('allItems now ${allItems.length}');
    items = allItems.where((item) => item.indexes != null).toList();
    print('items filtered ${items.length}');
    items.sort((a, b) => b.rank.compareTo(a.rank));
  }

  Widget buildSearchField() => Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Center(
        child: TextField(
          controller: searchController,
          autofocus: true,
          onChanged: (v) => setState(() {
            print('setState onChanged');
            query = v;
          }),
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                },
              ),
              hintText: 'Search among ${allItems.length}',
              border: InputBorder.none),
        ),
      ));

  final insertIndexForAll = 3;

  @override
  Widget build(BuildContext context) {
    print('build called. data=$data widget.dataToShow=${widget.dataToShow}');
    final navItems = List<LintSource?>.from(LintSource.values);
    navItems.insert(insertIndexForAll, null);

    return Scaffold(
      appBar: AppBar(
        title: buildSearchField(),
      ),
      drawer: data == null || widget.dataToShow != null
          ? null
          : LeftDrawer(data: data!, refreshDataFunc: openFetchingPage),
      body: buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: navItems
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(iconForLintSource(e)),
                  label: e == null ? 'All' : e.toString().substring(11),
                ))
            .toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        enableFeedback: true,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget buildBody() {
    if (!bootstrapped) {
      return const Center(child: Text('...'));
    }
    if (data == null) {
      return Center(
          child: OutlinedButton(
              onPressed: openFetchingPage, child: const Text('Fetch data')));
    }
    return ItemsListView(items: items);
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      print('setState _onItemTapped');
      _selectedIndex = index;
      refreshItems();
    });
  }
}
