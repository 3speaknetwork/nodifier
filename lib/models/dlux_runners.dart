import 'dart:convert';

import 'package:nodifier/models/safe_convert.dart';

class DRunner {
  final String name;
  final double g;
  DRunner({
    required this.name,
    required this.g,
  });
}

class DRunners {
  final List<DRunner> names;
  DRunners({
    required this.names,
  });

  factory DRunners.fromJson(Map<String, dynamic>? json) {
    var keys = json?.keys.toList();
    if (json == null || keys == null) {
      return DRunners(names: []);
    }
    var runners = keys.map((key) {
      return DRunner(name: key, g: asDouble(json[key], 'g'));
    }).toList();
    return DRunners(names: runners);
  }
}

class DluxQueue {
  final DRunners queue;

  DluxQueue({
    required this.queue,
  });

  factory DluxQueue.fromJson(Map<String, dynamic>? json) {
    return DluxQueue(queue: DRunners.fromJson(asMap(json, 'queue')));
  }

  factory DluxQueue.fromJsonString(String string) {
    return DluxQueue.fromJson(json.decode(string));
  }
}

class DluxRunners {
  final DRunners runners;

  DluxRunners({
    required this.runners,
  });

  factory DluxRunners.fromJson(Map<String, dynamic>? json) {
    return DluxRunners(runners: DRunners.fromJson(asMap(json, 'runners')));
  }

  factory DluxRunners.fromJsonString(String string) {
    return DluxRunners.fromJson(json.decode(string));
  }
}
