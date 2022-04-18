import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nodifier/add_hive_for_node.dart';
import 'package:nodifier/models/user_data_model.dart';
import 'package:nodifier/retry_screen.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({
    Key? key,
    required this.model,
    required this.result,
  }) : super(key: key);
  final UserDataModel model;
  final Function(UserDataModel) result;

  @override
  State<ManageNotificationsScreen> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final userPlatform = const MethodChannel('com.sagar.nodifier/user');
  late Future<UserDataModel> _loadData;
  UserDataModel model = UserDataModel(token: '', dlux: [], spkcc: []);
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData = _refreshData();
  }

  Future<UserDataModel> _refreshData() async {
    var userResult = await userPlatform.invokeMethod('data');
    debugPrint("userResult is $userResult");
    var model = UserDataModel.fromJsonString(userResult);
    setState(() {
      this.model = model;
    });
    return model;
  }

  Widget _headerTile(String text) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.only(left: 10, right: 10),
      tileColor: Colors.grey,
      title: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<String> update(List<String> spkcc, List<String> dlux) async {
    return await userPlatform.invokeMethod('update', <String, List<String>>{
      'spkcc': spkcc,
      'dlux': dlux,
    });
  }

  void updateWith(List<String> spkcc, List<String> dlux) async {
    try {
      setState(() {
        isLoading = true;
      });
      var userResult = await update(spkcc, dlux);
      var result = UserDataModel.fromJsonString(userResult);
      setState(() {
        model = result;
        isLoading = false;
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

  void _showBottomSheet(String type, String title) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text(
          'Are you sure?\nDo you want to stop receiving notifications for this node?'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('I confirm!'),
          onPressed: () {
            Navigator.of(context).pop();
            var spkcc = widget.model.spkcc;
            var dlux = widget.model.dlux;
            if (type == 'spkcc') {
              spkcc.remove(title);
            } else {
              dlux.remove(title);
            }
            updateWith(spkcc, dlux);
          },
        ),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  Widget _nodeTile(String type, String title) {
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _showBottomSheet(type, title);
        },
      ),
    );
  }

  Widget _listView() {
    if (model.dlux.isEmpty && model.spkcc.isEmpty) {
      return const Center(child: Text('No nodes found'));
    }
    return ListView.separated(
      itemBuilder: (c, i) {
        if (i == 0) {
          return _headerTile('Speak Nodes');
        } else if (i - 1 < model.spkcc.length) {
          return _nodeTile('spkcc', model.spkcc[i - 1]);
        } else if (i - 1 == model.spkcc.length) {
          return _headerTile('Dlux Nodes');
        } else {
          return _nodeTile('dlux', model.dlux[i - 2 - model.spkcc.length]);
        }
      },
      separatorBuilder: (c, i) => const Divider(height: 0),
      itemCount: model.dlux.length + model.spkcc.length + 2,
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder(
      future: _loadData,
      builder: (builder, snapshot) {
        if (snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: () => {_refreshData});
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return _listView();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(title: const Text('Manage Notifications'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var screen = AddHiveScreen(
            model: model,
            result: (response) {
              setState(() {
                model = response;
                widget.result(response);
              });
            },
          );
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
