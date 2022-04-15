import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:nodifier/models/dlux_runners.dart';
import 'package:nodifier/models/user_data_model.dart';

class DluxNode {
  final String name;
  final double g;
  final bool isRunner;
  final bool isQueue;
  DluxNode({
    required this.name,
    required this.g,
    required this.isRunner,
    required this.isQueue,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, required this.model}) : super(key: key);
  final UserDataModel model;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var isLoading = false;
  List<DluxNode> dluxList = [];

  @override
  void initState() {
    super.initState();
    getDluxData();
  }

  void getDluxData() async {
    const dluxRunnersApi = 'https://token.dlux.io/runners';
    const dluxQueueApi = 'https://token.dlux.io/queue';
    try {
      setState(() {
        isLoading = true;
        dluxList = [];
      });
      var responseDluxRunners = await get(Uri.parse(dluxRunnersApi));
      var responseDluxQueue = await get(Uri.parse(dluxQueueApi));
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
      setState(() {
        isLoading = false;
        dluxList = list;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        debugPrint('Error: ${e.toString()}');
        showError(e.toString());
      });
    }
  }

  void showError(String string) {
    Fluttertoast.showToast(
      msg: 'Error: $string',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget listView() {
    return ListView.separated(
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
                  Text((dluxList[i].g / 100.0).toStringAsFixed(2))
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodifier'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listView(),
    );
  }
}
