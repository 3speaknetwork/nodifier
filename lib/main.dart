import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nodifier/dashboard.dart';
import 'package:nodifier/models/user_data_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Nodifier'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fcmPlatform = const MethodChannel('com.sagar.nodifier/fcm');
  final authPlatform = const MethodChannel('com.sagar.nodifier/auth');
  final userPlatform = const MethodChannel('com.sagar.nodifier/user');
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    getFCMToken();
  }

  void getFCMToken() async {
    try {
      setState(() {
        isLoading = true;
      });
      var fcmResult = await fcmPlatform.invokeMethod('register');
      debugPrint("fcmResult is $fcmResult");
      var authResult = await authPlatform.invokeMethod('login');
      debugPrint("authResult is $authResult");
      var userResult = await userPlatform.invokeMethod('data');
      debugPrint("userResult is $userResult");
      var result = UserDataModel.fromJsonString(userResult);
      if (result != null) {
        setState(() {
          isLoading = false;
          var dashboard = DashboardScreen(model: result);
          var route = MaterialPageRoute(builder: (c) => dashboard);
          Navigator.of(context).pushReplacement(route);
        });
      } else {
        setState(() {
          isLoading = false;
          showError('Invalid JSON received.');
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        debugPrint('Error: ${e.toString()}');
        showError(e.toString());
      });
    }
  }

  void showError(String String) {
    Fluttertoast.showToast(
      msg: 'Error: $String',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                child: const Text('Let\'s get started'),
                onPressed: () async {
                  getFCMToken();
                },
              ),
      ),
    );
  }
}
