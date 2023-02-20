import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'task.dart';

export 'task.dart';

const String projectNameKey = "name";
const String projectTasksKey = "tasks";
const String uidKey = "uuid";
const String iconKey = "icon";

class Project extends StatelessWidget {
  int? id;
  String? uid;
  String name = "";
  String? icon;
  List<Task> tasks = [];

  Project({required this.tasks, required this.name});

  Project.create({required this.name, this.icon = "list"}) : uid = Uuid().v1();

  Project.fromMap(Map<dynamic, dynamic> map) {
    id = map[idKey];
    uid = map[uidKey];
    icon = map[iconKey];
    name = map[projectNameKey];
    tasks = (jsonDecode(map[projectTasksKey]) as List)
        .map((taskString) => Task.fromMap(jsonDecode(taskString)))
        .toList();
  }

  Map<String, dynamic> toMap() => {
        idKey: id,
        uidKey: uid,
        iconKey: icon,
        projectNameKey: name,
        projectTasksKey:
            jsonEncode(tasks.map((t) => jsonEncode(t.toMap())).toList())
      };

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
