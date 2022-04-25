import 'dart:convert';

import 'package:nodifier/models/safe_convert.dart';

class UserDataModel {
  final List<String> spkcc;
  final List<String> dlux;
  final List<String> duat;
  // token
  final String token;

  UserDataModel({
    required this.spkcc,
    required this.dlux,
    required this.duat,
    this.token = "",
  });

  factory UserDataModel.fromJson(Map<String, dynamic>? json) => UserDataModel(
        spkcc: asList(json, 'spkcc').map((e) => e.toString()).toList(),
        dlux: asList(json, 'dlux').map((e) => e.toString()).toList(),
        duat: asList(json, 'duat').map((e) => e.toString()).toList(),
        token: asString(json, 'token'),
      );

  factory UserDataModel.fromJsonString(String string) =>
      UserDataModel.fromJson(json.decode(string));

  Map<String, dynamic> toJson() => {
        'spkcc': spkcc.map((e) => e),
        'dlux': dlux.map((e) => e),
        'duat': duat.map((e) => e),
        'token': token,
      };
}
