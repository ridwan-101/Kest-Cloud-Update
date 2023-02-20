import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:kingslist/models/project.dart';

export 'package:kingslist/models/project.dart';

class DBProvider {
  DBProvider._privateConstructor();
// DBProvider needed a constructor to work
  static final DBProvider db = DBProvider._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<void> initDatabase() async {
    _database = await initDB();
  }

  Future<Database> initDB({bool refresh = false}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = join(appDocDir.path, "database.db");

    if (await File(path).exists() && !refresh) {
      debugPrint("DBProvider: loading the database.");

      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));
        },
      );
    } else {
      debugPrint("DBProvider: copying database from asset to device.");

      ByteData data = await rootBundle.load("database/database.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));
        },
      );
    }
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    var res = await db.update("Projects", project.toMap(),
        where: "id = ?", whereArgs: [project.id]);
    return res;
  }

  Future<int> deleteProject(Project task) async {
    final db = await database;
    var res =
        await db.delete("Projects", where: "id = ?", whereArgs: [task.id]);
    return res;
  }

  Future<Future<int>> addProject(Project project) async {
    final db = await database;

    var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Projects');
    Object? id = table.first['id'];
    project.id = (id ?? 0) as int?;
    var map = project.toMap();

    //return db.insert("Projects", {"id": map[idKey], "uuid": map[uidKey], "tasks": map[projectTasksKey], "name": map[projectNameKey]});
    return db.insert("Projects", map);
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    List<Map> res;
    res = await db.query('Projects');

    print("The length of projects: ${res.length}");

    return res.isNotEmpty
        ? res.map((r) {
            return Project.fromMap(r);
          }).toList()
        : [];
  }

  Future<Object?> getNextId() async {
    final db = await database;

    var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Projects');
    Object? id = table.first['id'];

    return id;
  }
}

//final dbProvider = DBProvider();
