import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<String> update(List<String> spkcc, List<String> dlux) async {
    return await userPlatform.invokeMethod('update', <String, List<String>>{
      'spkcc': spkcc,
      'dlux': dlux,
    });
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

  void updateWith(List<String> spkcc, List<String> dlux) async {
    try {
      setState(() {
        isLoading = true;
      });
      var userResult = await update(spkcc, dlux);
      var result = UserDataModel.fromJsonString(userResult);
      widget.result(result);
      setState(() {
        isLoading = false;
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
            updateWith(spkcc, dlux);
          },
        ),
        BottomSheetAction(
          title: const Text('dlux'),
          onPressed: () {
            var spkcc = widget.model.spkcc;
            var dlux = widget.model.dlux + [text];
            updateWith(spkcc, dlux);
          },
        ),
        BottomSheetAction(
          title: const Text('spkcc & dlux'),
          onPressed: () {
            var spkcc = widget.model.spkcc + [text];
            var dlux = widget.model.dlux + [text];
            updateWith(spkcc, dlux);
          },
        ),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(title: const Text('Manage Notifications'));
  }

  Widget _body() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        autocorrect: false,
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
            _showBottomSheet();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
