import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodifier/models/user_data_model.dart';
import 'package:nodifier/retry_screen.dart';

class AddHiveScreen extends StatefulWidget {
  const AddHiveScreen({Key? key, required this.model}) : super(key: key);
  final UserDataModel model;

  @override
  State<AddHiveScreen> createState() => _AddHiveScreenState();
}

class _AddHiveScreenState extends State<AddHiveScreen> {
  var text = '';
  late TextEditingController _controller;
  final userPlatform = const MethodChannel('com.sagar.nodifier/user');
  late Future<UserDataModel> _loadData;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadData = _refreshData();
  }

  Future<UserDataModel> _refreshData() async {
    var userResult = await userPlatform.invokeMethod('data');
    debugPrint("userResult is $userResult");
    return UserDataModel.fromJsonString(userResult);
  }

  Widget _listView(UserDataModel model) {
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
          UserDataModel model = snapshot.data! as UserDataModel;
          return _listView(model);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            text = value;
          });
        },
        onEditingComplete: () {
          debugPrint('Hello');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }
}
