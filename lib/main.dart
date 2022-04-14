import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  void getFCMToken() async {
    try {
      var fcmResult = await fcmPlatform.invokeMethod('register');
      debugPrint("fcmResult is $fcmResult");
      var authResult = await authPlatform.invokeMethod('login');
      debugPrint("authResult is $authResult");
      var userResult = await userPlatform.invokeMethod('data');
      debugPrint("userResult is $userResult");
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getFCMToken();
        },
        tooltip: 'Add a node',
        child: const Icon(Icons.add),
      ),
    );
  }
}
