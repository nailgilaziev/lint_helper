import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lint_helper/fetchers/all_rules_from_html.dart';
import 'package:lint_helper/fetchers/rules_from_yaml.dart';
import 'package:lint_helper/models/all_data.dart';
import 'package:lint_helper/models/lint_source.dart';
import 'package:url_launcher/url_launcher.dart';

class FetchingPage extends StatefulWidget {
  const FetchingPage({Key? key, required this.data}) : super(key: key);

  final AllData? data;

  @override
  _FetchingPageState createState() => _FetchingPageState();
}

enum JobState { idle, started, success, failure }

class Job {
  String name;
  String url;
  JobState state = JobState.idle;

  String report = '';
  Future<bool> Function(Job job) work;

  Job(this.name, this.url, this.work);
}

class _FetchingPageState extends State<FetchingPage> {
  late AllData? data = widget.data;
  int stage = -1;

  late final jobs = [
    Job('Fetching all lint rules from official page...', AllRulesFetcher.url,
        (job) async {
      final fresh = await AllRulesFetcher().fetchAndParse();
      data!.all = fresh;
      // job.report = '\n- old rules:${old.length - fresh.length}\n- updated rules: 234';
      job.report = '\n\n- rules fetched:${fresh.length}';
      return true;
    }),
    for (final source in LintSource.values.take(4))
      Job('Fetching and parsing $source lint rules...', urlForSource(source),
          (job) async {
        final names = await YamlRules().fetchRules(source);
        int filled = data!.fillItemsForSource(source, names);
        job.report = '\n\n- fetched:${names.length} (valid:$filled)';
        return true;
      }),
  ];

  void runJobs() async {
    stage = 0;
    data = AllData();
    while (stage < jobs.length) {
      var job = jobs[stage];
      job.state = JobState.started;
      setState(() {});
      bool workResult;
      try {
        workResult = await job.work(job);
      } catch (e, st) {
        workResult = false;
        print('exception happens while exec job work. stage=$stage');
        print(st);
        job.report = '\n\n-$e';
        print(e);
      }
      if (workResult) {
        job.state = JobState.success;
      } else {
        job.state = JobState.failure;
      }
      stage++;
    }
    setState(() {});
  }

  Future<void> saveData() async {
    bool saved;
    try {
      saved = await data!.saveToDb();
    } catch (e) {
      saved = false;
      warn('Problems with prefs:\n$e');
    }
    if (!saved) {
      setState(() {
        stage = 99;
      });
    } else {
      print('returning new data');
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ListView(
            children: [
              const SizedBox(height: 28),
              if (stage == -1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'This will make network requests and fetch all required data',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (stage == -1)
                ElevatedButton(
                    onPressed: () => runJobs(),
                    child: const Text('REFRESH ALL DATA')),
              if (stage == -1)
                Padding(
                  padding: EdgeInsets.only(left: pl, bottom: 8.0, top: 8),
                  child: Text(
                      'Previous fetching:\n${data?.syncDate?.toString() ?? 'never'}'),
                ),
              ...jobs.map(jobToWidget).toList(),
              const SizedBox(height: 16),
              if (stage == jobs.length &&
                  jobs.any((element) => element.state == JobState.failure))
                const Text(
                    'One of the jobs failed! Saving can cause unpredictable behaviour! Better is try to fetch later.',
                    textScaleFactor: 1.2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.deepOrange)),
              if (stage == jobs.length)
                ElevatedButton(
                    onPressed: saveData, child: const Text('SAVE DATA')),
              if (stage == jobs.length + 1)
                const Text('Saving...',
                    textScaleFactor: 1.6, textAlign: TextAlign.center),
              if (stage == 99)
                const Text('Oops. Failed on saving!',
                    textScaleFactor: 1.6,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.deepOrange)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget jobToWidget(Job job) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildProgress(job),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(job.name + job.report),
          )),
          TextButton(
              onPressed: () {
                open(job.url);
              },
              child: const Text('VIEW')),
        ],
      ),
    );
  }

  final pl = 40.0;

  Widget buildProgress(Job job) {
    Icon ic = const Icon(
      Icons.signal_cellular_connected_no_internet_4_bar_rounded,
      color: Colors.grey,
    );
    if (job.state == JobState.success) {
      ic = const Icon(
        Icons.done,
        color: Colors.lightGreen,
      );
    }
    if (job.state == JobState.failure) {
      ic = const Icon(
        Icons.error_outline,
        color: Colors.deepOrange,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: job.state != JobState.started
          ? ic
          : const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              )),
    );
  }

  void open(String url) async {
    await canLaunch(url)
        ? await launch(url)
        : warn('Could not launch url $url');
  }

  void warn(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
  }
}
