import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodifier/add_hive_for_node.dart';
import 'package:nodifier/models/user_data_model.dart';
import 'package:nodifier/retry_screen.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({Key? key, required this.model})
      : super(key: key);
  final UserDataModel model;

  @override
  State<ManageNotificationsScreen> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final userPlatform = const MethodChannel('com.sagar.nodifier/user');
  late Future<UserDataModel> _loadData;
  UserDataModel model = UserDataModel(token: '', dlux: [], spkcc: []);

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

  Widget _listView() {
    if (model.dlux.isEmpty && model.spkcc.isEmpty) {
      return const Center(child: Text('No nodes found'));
    }
    return ListView.separated(
      itemBuilder: (c, i) {
        if (i == 0) {
          return const ListTile(
            title: Text('Speak Nodes'),
          );
        } else if (i - 1 < model.spkcc.length) {
          return ListTile(
            title: Text(model.spkcc[i - 1]),
          );
        } else if (i - 1 == model.spkcc.length) {
          return const ListTile(
            title: Text('Dlux Nodes'),
          );
        } else {
          return ListTile(
            title: Text(model.dlux[i - 2 - model.spkcc.length]),
          );
        }
      },
      separatorBuilder: (c, i) => const Divider(),
      itemCount: model.dlux.length + model.spkcc.length + 2,
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
