import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nodifier/models/user_data_model.dart';

class AddHiveScreen extends StatefulWidget {
  const AddHiveScreen({
    Key? key,
    required this.model,
    required this.result,
  }) : super(key: key);
  final UserDataModel model;
  final Function(UserDataModel) result;

  @override
  State<AddHiveScreen> createState() => _AddHiveScreenState();
}

class _AddHiveScreenState extends State<AddHiveScreen> {
  var isLoading = false;
  var text = '';
  final userPlatform = const MethodChannel('com.sagar.nodifier/user');

  Future<String> update(
      List<String> spkcc, List<String> dlux, List<String> duat) async {
    return await userPlatform.invokeMethod('update', <String, List<String>>{
      'spkcc': spkcc,
      'dlux': dlux,
      'duat': duat,
    });
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateWith(
      List<String> spkcc, List<String> dlux, List<String> duat) async {
    try {
      setState(() {
        isLoading = true;
      });
      var userResult = await update(spkcc, dlux, duat);
      var result = UserDataModel.fromJsonString(userResult);
      setState(() {
        isLoading = false;
        widget.result(result);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        debugPrint('Error: ${e.toString()}');
        showError(e.toString());
      });
    }
  }

  void _showBottomSheet() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Select action'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('spkcc'),
          onPressed: () {
            var spkcc = widget.model.spkcc + [text];
            var dlux = widget.model.dlux;
            var duat = widget.model.duat;
            updateWith(spkcc, dlux, duat);
          },
        ),
        BottomSheetAction(
          title: const Text('dlux'),
          onPressed: () {
            var spkcc = widget.model.spkcc;
            var dlux = widget.model.dlux + [text];
            var duat = widget.model.duat;
            updateWith(spkcc, dlux, duat);
          },
        ),
        BottomSheetAction(
          title: const Text('duat'),
          onPressed: () {
            var spkcc = widget.model.spkcc;
            var dlux = widget.model.dlux;
            var duat = widget.model.duat + [text];
            updateWith(spkcc, dlux, duat);
          },
        ),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(title: const Text('Add Node name'));
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        autocorrect: false,
        decoration: const InputDecoration(
            hintText: 'Enter hive user name here. Do not add `@` sign.'),
        onChanged: (newText) {
          setState(() {
            text = newText;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (text.isNotEmpty) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            currentFocus.unfocus();
            _showBottomSheet();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
