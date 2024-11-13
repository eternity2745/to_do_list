import 'dart:developer';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseService {

  static const _dbname = "ToDoList.db";
  static const _dbversion = 1;

  static const tableName1 = "Upcoming";
  static const t1_columnName1 = "id";
  static const t1_columnName2 = "Task_Name";
  static const t1_columnName3 = "Created";
  static const t1_columnName4 = "End_Date";
  static const t1_columnName5 = "End_Time";
  static const t1_columnName6 = "Period_Of_Hour";

  static const tableName2 = "Completed";
  static const t2_columnName1 = "id";
  static const t2_columnName2 = "Completed_Date";
  static const t2_columnName3 = "Completed_Time";

  static const tableName3 = "Overdue";
  static const t3_columnName1 = "id"; 
  
  //singleton class
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbname);
    return await openDatabase(path, version: _dbversion, 
    onCreate: (db, version) {
      db.execute('''
              CREATE TABLE $tableName1 (
              $t1_columnName1 INT PRIMARY KEY,
              $t1_columnName2 VARCHAR(255) NOT NULL,
              $t1_columnName3 DATE NOT NULL,
              $t1_columnName4 DATE NOT NULL,
              $t1_columnName5 TIME NOT NULL,
              $t1_columnName6 CHAR(2) NOT NULL
              )
      ''');

      db.execute('''
              CREATE TABLE $tableName2 (
              $t2_columnName1 INT NOT NULL,
              $t2_columnName2 DATE NOT NULL,
              $t2_columnName3 TIME NOT NULL,
              FOREIGN KEY ($t2_columnName1) REFERENCES Upcoming($t1_columnName1)
              )
      ''');

      db.execute(''' 
              CREATE TABLE $tableName3 (
              $t3_columnName1 INT NOT NULL,
              FOREIGN KEY ($t3_columnName1) REFERENCES $tableName1($t1_columnName1)
               )
      ''');
    }
    );
  }

  Future<void> createTask(String taskName, String date, String time, String periodOfHour) async {

    final db = await _instance.database;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    log(id);
    final created = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    await db!.insert(
      tableName1,
      {
        t1_columnName1: id,
        t1_columnName2: taskName,
        t1_columnName3: created,
        t1_columnName4: date,//"${date.length == 10? '${date.substring(6)}/${date.substring(3,5)}/${date.substring(0,2)}' : '${date.substring(5)}/${date.substring(2,4)}/${date.substring(0,1)}'}",
        t1_columnName5: "$time:00",
        t1_columnName6: periodOfHour
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future getTaskDetails() async {
    final db = await _instance.database;
    final List<Map<String, Object?>> result = await db!.query(
      tableName1
      );
    return result;
  }

  Future getUpcomingTask({int? limit}) async {
    final db = await _instance.database;

    if (limit != null) {
    final List<Map<String, Object?>> result = await db!.query(
      tableName1,
      orderBy: "$t1_columnName4, $t1_columnName5",
      limit: limit
      );
    return result;
    }else{
      final List<Map<String, Object?>> result = await db!.query(
      tableName1,
      orderBy: "$t1_columnName4, $t1_columnName5",
      );
    return result;
    }
  }

  Future deleteTask(int id) async {
    final db = await _instance.database;

    await db!.delete(
      tableName1,
      where: "id = ?",
      whereArgs: [id]
    );

  }

  Future getStatistics() async {
    final db = await _instance.database;

    List<Map<String, Object?>> upcomingTasks = await db!.rawQuery(
      "SELECT count(*) FROM $tableName1"
    );

    List<Map<String, Object?>> completedTasks = await db.rawQuery(
      "SELECT count(*) FROM $tableName2"
    );

    List<Map<String, Object?>> overdueTasks = await db.rawQuery(
      "SELECT count(*) FROM $tableName3"
    );
    return [upcomingTasks[0]['count(*)'], completedTasks[0]['count(*)'], overdueTasks[0]['count(*)']];

  }

  Future getOverdueTasks() async {
    final db = await _instance.database;

    List<Map<String, Object?>> result = await db!.query(
      tableName3,
      orderBy: "$t1_columnName4, $t1_columnName5"
    );

    return result;
  }

  Future updateOverDueTasks() async {

    final db = await _instance.database;
    
    DateTime dateTime = DateTime.now();
    String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    String formattedTime = "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";

    var upcomingTasks = await db!.query(
      tableName1,
      where: "$t1_columnName4 <= ? AND $t1_columnName5 <= ?",
      whereArgs: [formattedDate, formattedTime],
      orderBy: "$t1_columnName4, $t1_columnName5"
    );
    log("$upcomingTasks");

    if (upcomingTasks.isEmpty) {
      return false;
    }else{
      Map<String, Object?> values = {};
      for (var i in upcomingTasks) {
        values.addEntries(i.entries);
      }
      await db.insert(
        tableName3,
        values
        );
    }
  }

}