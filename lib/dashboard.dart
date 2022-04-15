import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:nodifier/add_hive_id.dart';
import 'package:nodifier/drawer.dart';
import 'package:nodifier/models/dlux_runners.dart';
import 'package:nodifier/models/user_data_model.dart';
import 'package:nodifier/retry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
    required this.model,
    required this.runnerPath,
    required this.queuePath,
    required this.title,
  }) : super(key: key);
  final UserDataModel model;
  final String runnerPath;
  final String queuePath;
  final String title;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<DluxNode>> _loadData;

  @override
  void initState() {
    super.initState();
    _loadData = _getDluxData();
  }

  Future<List<DluxNode>> _getDluxData() async {
    try {
      var responseDluxRunners = await get(Uri.parse(widget.runnerPath));
      var responseDluxQueue = await get(Uri.parse(widget.queuePath));
      var dluxRunners =
          DluxRunners.fromJsonString(responseDluxRunners.body).runners.names;
      var dluxQueue =
          DluxQueue.fromJsonString(responseDluxQueue.body).queue.names;
      List<DluxNode> list = [];
      while (dluxQueue.isNotEmpty || dluxRunners.isNotEmpty) {
        var last = dluxRunners.isNotEmpty ? dluxRunners.last : dluxQueue.last;
        if (dluxRunners.where((e) => e.name == last.name).length == 1 &&
            dluxQueue.where((e) => e.name == last.name).length == 1) {
          list.add(DluxNode(
              name: last.name, g: last.g, isQueue: true, isRunner: true));
          dluxRunners.removeWhere((e) => e.name == last.name);
          dluxQueue.removeWhere((e) => e.name == last.name);
        } else if (dluxQueue.where((e) => e.name == last.name).length == 1) {
          list.add(DluxNode(
              name: last.name, g: last.g, isQueue: true, isRunner: false));
          dluxQueue.removeWhere((e) => e.name == last.name);
        } else if (dluxRunners.where((e) => e.name == last.name).length == 1) {
          list.add(DluxNode(
              name: last.name, g: last.g, isQueue: true, isRunner: false));
          dluxRunners.removeWhere((e) => e.name == last.name);
        }
      }
      list.sort((a, b) => a.g > b.g
          ? -1
          : a.g < b.g
              ? 1
              : 0);
      return list;
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      _showError(e.toString());
      rethrow;
    }
  }

  void _showError(String string) {
    Fluttertoast.showToast(
      msg: 'Error: $string',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget _listView(List<DluxNode> dluxList) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: RefreshIndicator(
        onRefresh: () {
          return _loadData = _getDluxData();
        },
        child: ListView.separated(
          itemBuilder: (c, i) {
            return ListTile(
              title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dluxList[i].name,
                        style: TextStyle(
                          color: widget.model.dlux.contains(dluxList[i].name)
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                      Text((dluxList[i].g / 1000.0).toStringAsFixed(3))
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      dluxList[i].isQueue
                          ? const Icon(Icons.check)
                          : const Icon(Icons.clear),
                      const SizedBox(height: 5),
                      const Text('Consensus?')
                    ],
                  ),
                  const SizedBox(width: 5),
                  Column(
                    children: [
                      dluxList[i].isRunner
                          ? const Icon(Icons.check)
                          : const Icon(Icons.clear),
                      const SizedBox(height: 5),
                      const Text('Runner?')
                    ],
                  )
                ],
              ),
            );
          },
          separatorBuilder: (c, i) => const Divider(),
          itemCount: dluxList.length,
        ),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder(
      future: _loadData,
      builder: (builder, snapshot) {
        if (snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: () => {_getDluxData});
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          List<DluxNode> items = snapshot.data! as List<DluxNode>;
          return _listView(items);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _body(),
      drawer: DrawerScreen(model: widget.model),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var settings = AddHiveScreen(model: widget.model);
          var route = MaterialPageRoute(builder: (c) => settings);
          Navigator.of(context).push(route);
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
