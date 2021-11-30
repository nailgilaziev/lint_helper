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
    searchController.addListener(() => setState(() {
          print('search field content change provoked setState');
          query = searchController.text;
        }));
    initializeData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void initializeData() async {
    if (widget.dataToShow != null) {
      useData(widget.dataToShow!);
      return;
    } else {
      final d = AllData();
      d.addListener(() => setState(() {
            /// когда через интерфейс добавления "моих правил" будут добавлены новые элементы
            /// и если мы будем на вкладке my то интерфейс должен автоматически подхватить эти изменения
            /// тоже самое должно произойти и при refresh all data
            updateTabItems();
          }));
      if (await d.fillFromDb()) {
        useData(d);
      } else {
        openFetchingPage();
      }
    }
    setState(() {
      print('bootstrapped setState');
      bootstrapped = true;
    });
  }

  void useData(AllData data) {
    this.data = data;
    updateTabItems();
  }

  Future<void> openFetchingPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute<AllData>(
            builder: (BuildContext context) => FetchingPage(data: data)));
    if (result != null) {
      setState(() {
        print('saving result from fetching page - setState');
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

  List<Item> tabItems = [];

  String get query => _query;

  set query(String query) {
    _query = query;
    print('new query = [$query]');
    updateShowedItemsForTab();
  }

  List<Item> filteredItems = [];

  void updateTabItems() {
    tabItems = itemsForIndex(_selectedIndex);
    print('allItems now ${tabItems.length}');
    updateShowedItemsForTab();
  }

  void updateShowedItemsForTab() {
    print('.updateShowedItemsForTab()');
    if (query.isEmpty) {
      for (final item in tabItems) {
        item.resetIndexes();
      }
    } else {
      for (final item in tabItems) {
        item.match(query);
      }
    }
    filteredItems = tabItems.where((item) => item.indexes != null).toList();
    print('filteredItems count ${filteredItems.length}');
    filteredItems.sort((a, b) => b.rank.compareTo(a.rank));
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
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                },
              ),
              hintText: 'Search among ${tabItems.length}',
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
          : LeftDrawer(data: data!, openFetchingPageFunc: openFetchingPage),
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
    return ItemsListView(items: filteredItems);
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
    print('._onItemTapped($index)');
    setState(() {
      _selectedIndex = index;
      updateTabItems();
    });
  }
}
