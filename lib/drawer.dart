import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nodifier/dashboard.dart';
import 'package:nodifier/models/user_data_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key, required this.model}) : super(key: key);
  final UserDataModel model;

  Widget _homeMenu(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.chat_bubble),
      title: const Text("Speak Nodes"),
      onTap: () {
        Navigator.pop(context);
        var dashboard = DashboardScreen(
          title: 'Speak Nodes',
          model: model,
          runnerPath: 'https://spkinstant.hivehoneycomb.com/runners',
          queuePath: 'https://spkinstant.hivehoneycomb.com/queue',
        );
        var route = MaterialPageRoute(builder: (context) => dashboard);
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _dluxNodes(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dashboard),
      title: const Text("Dlux nodes"),
      onTap: () {
        var dashboard = DashboardScreen(
          title: 'Dlux Nodes',
          model: model,
          runnerPath: 'https://token.dlux.io/runners',
          queuePath: 'https://token.dlux.io/queue',
        );
        var route = MaterialPageRoute(builder: (context) => dashboard);
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _visitDlux(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.web),
      title: const Text("Visit Dlux.io"),
      onTap: () {
        launch('https://www.dlux.io/');
      },
    );
  }

  Widget _joinDluxDiscord(BuildContext context) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.discord),
      title: const Text("Join Dlux Discord"),
      onTap: () {
        launch('https://discord.gg/Beeb38j');
      },
    );
  }

  Widget _joinThreeSpeakDiscord(BuildContext context) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.discord),
      title: const Text("Join 3Speak Discord"),
      onTap: () {
        launch('https://discord.me/3speak');
      },
    );
  }

  Widget _visitThreeSpeak(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.video_collection),
      title: const Text("Visit 3speak.tv"),
      onTap: () {
        launch('https://3speak.tv');
      },
    );
  }

  Widget _readLightPaper(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bolt),
      title: const Text("Read Light Paper"),
      onTap: () {
        launch('https://hive.blog/@spknetwork/spk-network-light-paper');
      },
    );
  }

  Widget _drawerHeader(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: [
          Image.asset(
            "assets/hive.png",
            width: 60,
            height: 52,
          ),
          const SizedBox(height: 5),
          Text(
            "Nodifier",
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 5),
          Text(
            "sagarkothari88",
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Colors.blueGrey,
    );
  }

  Widget _drawerMenu(BuildContext context) {
    return ListView(
      children: [
        _drawerHeader(context),
        _dluxNodes(context),
        _divider(),
        _visitDlux(context),
        _divider(),
        _joinDluxDiscord(context),
        _divider(),
        _divider(),
        _divider(),
        _homeMenu(context),
        _divider(),
        _visitThreeSpeak(context),
        _divider(),
        _joinThreeSpeakDiscord(context),
        _divider(),
        _readLightPaper(context),
        _divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: _drawerMenu(context));
  }
}
