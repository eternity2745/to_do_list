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
  static const t2_columnName2 = "Task_Name";
  static const t2_columnName3 = "Completed_Date";
  static const t2_columnName4 = "Completed_Time";
  static const t2_columnName5 = "Completed_Period_Of_Hour";
  static const t2_columnName6 = "Created";
  static const t2_columnName7 = "End_Date";
  static const t2_columnName8 = "End_Time";
  static const t2_columnName9 = "Period_Of_Hour";


  static const tableName3 = "Overdue";
  static const t3_columnName1 = "id"; 
  static const t3_columnName2 = "Task_Name";
  static const t3_columnName3 = "Created";
  static const t3_columnName4 = "End_Date";
  static const t3_columnName5 = "End_Time";
  static const t3_columnName6 = "Period_Of_Hour";
  
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
              $t2_columnName1 INT PRIMARY KEY,
              $t2_columnName2 VARCHAR(255) NOT NULL,
              $t2_columnName3 DATE NOT NULL,
              $t2_columnName4 TIME NOT NULL,
              $t2_columnName5 CHAR(2) NOT NULL,
              $t2_columnName6 DATE NOT NULL,
              $t2_columnName7 DATE NOT NULL,
              $t2_columnName8 TIME NOT NULL,
              $t2_columnName9 CHAR(2) NOT NULL
              )
      ''');

      db.execute(''' 
              CREATE TABLE $tableName3 (
              $t3_columnName1 INT PRIMARY KEY,
              $t3_columnName2 VARCHAR(255) NOT NULL,
              $t3_columnName3 DATE NOT NULL,
              $t3_columnName4 DATE NOT NULL,
              $t3_columnName5 TIME NOT NULL,
              $t3_columnName6 CHAR(2) NOT NULL
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
    log("1 Upc");
    final List<Map<String, Object?>> result = await db!.query(
      tableName1,
      orderBy: "$t1_columnName4, $t1_columnName5",
      limit: limit
      );
    log("2 Upc");
    return result;
    }else{
      final List<Map<String, Object?>> result = await db!.query(
      tableName1,
      orderBy: "$t1_columnName4, $t1_columnName5",
      );
    return result;
    }
  }

  Future deleteTask(int id, int tableNumber) async {
    final db = await _instance.database;

    await db!.delete(
      tableNumber == 1? tableName1 : tableNumber == 2? tableName2 : tableName3,
      where: "id = ?",
      whereArgs: [id]
    );

  }

  Future completeTask(Map<String, Object?> taskDetail, int tableNumber) async {
    final db = await _instance.database;
    log("TASKDETAIL\n$taskDetail");
    taskDetail.remove("Deleted");
    await db!.insert(
      tableName2, 
      taskDetail,
      conflictAlgorithm: ConflictAlgorithm.replace
      );
    await db.delete(
      tableNumber == 1? tableName1 : tableName3,
      where: "id = ?",
      whereArgs: [taskDetail['id']]
    );
  }

  Future getCompletedTasks({int? limit}) async {
    final db = await _instance.database;

    if (limit == null) {
    List<Map<String, Object?>> result = await db!.query(
      tableName2,
      orderBy: "$t2_columnName3, $t2_columnName4"
    );
    return result;
    }else{
      List<Map<String, Object?>> result = await db!.query(
      tableName2,
      orderBy: "$t2_columnName3, $t2_columnName4",
      limit: limit
    );
    return result;
    }
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
      List<Map<String, Object?>> values = [];
      List ids = [];
      if (upcomingTasks.length == 1) {
        for (var i in upcomingTasks) {
          values.add(i);
          ids.add(i['id']);
          await db.insert(
          tableName3,
          i,
          conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
      }else{
        await db.transaction((txn) async {
          final batch = txn.batch();
          for (var i in upcomingTasks) {
            values.add(i);
            ids.add(i['id']);
            batch.insert(
            tableName3,
            i,
            conflictAlgorithm: ConflictAlgorithm.replace
            );
        }
      }
      );
    }
      
      log("1 Over");

      await db.transaction((txn) async {
        final batch = txn.batch();
        for (var i in ids) {
          batch.delete(
            tableName1,
            where: "id = ?",
            whereArgs: [i]
          );
        await batch.commit();
        }
      }
      );
      log("2 Over");
      return values;
    }
  }
}