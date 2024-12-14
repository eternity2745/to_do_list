import 'package:intl/intl.dart';
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

  Future createTask(String taskName, String date, String time, String periodOfHour) async {

    final db = await _instance.database;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final dateTime = DateTime.now();
    final created = "${dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day}/${dateTime.month}/${dateTime.year}";
    DateFormat inputFormat = DateFormat("dd/MM/yyyy");
    DateFormat outputFormat = DateFormat("yyyy-MM-dd");
    var dueDate = inputFormat.parse(date);
    String dueDateOG = outputFormat.format(dueDate);
  
    await db!.insert(
      tableName1,
      {
        t1_columnName1: id,
        t1_columnName2: taskName,
        t1_columnName3: created,
        t1_columnName4: dueDateOG,
        t1_columnName5: "$time:00",
        t1_columnName6: periodOfHour
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  return [id, created];
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
    taskDetail.remove("Deleted");
    DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    var dueDate = inputFormat.parse(taskDetail['End_Date'] as String);
    taskDetail['End_Date'] = outputFormat.format(dueDate);
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
      orderBy: "$t2_columnName3 DESC, $t2_columnName4 DESC"
    );
    return result;
    }else{
      List<Map<String, Object?>> result = await db!.query(
      tableName2,
      orderBy: "$t2_columnName3 DESC, $t2_columnName4 DESC",
      limit: limit
    );
    return result;
    }
  }

  Future  getStatistics() async {
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
    String formattedDate = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
    String hour = dateTime.hour < 10 ? '0${dateTime.hour}' : '${dateTime.hour}';
    String minutes = dateTime.minute < 10 ? '0${dateTime.minute}' : '${dateTime.minute}';
    String seconds = dateTime.second < 10 ? '0${dateTime.second}' : '${dateTime.second}';
    String formattedTime = "$hour:$minutes:$seconds";

    var upcomingTasks = await db!.rawQuery(
      "SELECT * FROM $tableName1 WHERE $t1_columnName4 < $formattedDate OR ($t1_columnName4 = '$formattedDate' AND $t1_columnName5 <= '$formattedTime') ORDER BY $t1_columnName4, $t1_columnName5"
    );
    List<Map<String, Object?>> values = [];
    if (upcomingTasks.isEmpty) {
      return values;
    }else{
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
          await batch.commit();
        }
      }
      );
    }

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
      return values;
    }
  }

  Future updateUpcomingTasks({int? id}) async {
    final db = await _instance.database;

    if (id == null) {
      var upcTask = await db!.query(
        tableName1,
        where: "id = (SELECT MAX(id) FROM $tableName1)" 
      );
      return upcTask;
    }else{
      var upcTask = await db!.query(
        tableName1,
        where: "id = $id"
      );
      return upcTask;
    }
  }

  Future deleteUpcomingTask(int id) async {
    final db = await _instance.database;
    await db!.delete(
        tableName1,
        where: "id = ?",
        whereArgs: [id]
      );
  }

  Future deleteOverdueTask(int id) async {
    final db = await _instance.database;
    await db!.delete(
        tableName3,
        where: "id = ?",
        whereArgs: [id]
      );
  }

  Future deleteCompletedTask(int id) async {
    final db = await _instance.database;
    await db!.delete(
        tableName2,
        where: "id = ?",
        whereArgs: [id]
      );
  }

  Future editTask(int id, int tableNumber, {String? dueDate, String? dueTime, String? duePeriod}) async {
    final db = await _instance.database;

    if (dueDate != null) {
      DateFormat inputformat = DateFormat('dd/MM/yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      var date = inputformat.tryParse(dueDate);
      if (date != null) {
      dueDate = outputFormat.format(date);
      }

      if (tableNumber == 1) {
        await db!.rawUpdate(
            "UPDATE $tableName1 SET $t1_columnName4 = '$dueDate' WHERE $t1_columnName1 = $id"
          );
      }else{
        await db!.rawUpdate(
          "UPDATE $tableName3 SET $t3_columnName4 = '$dueDate' WHERE $t3_columnName1 = $id"
        );
      }
    }else{
      if (tableNumber == 1) {
        await db!.rawUpdate(
            "UPDATE $tableName1 SET $t1_columnName5 = '$dueTime:00' WHERE $t1_columnName1 = $id"
          );
        await db.rawUpdate(
            "UPDATE $tableName1 SET $t1_columnName6 = '$duePeriod' WHERE $t1_columnName1 = $id"
        );

      }else{
          await db!.rawUpdate(
            "UPDATE $tableName3 SET $t1_columnName5 = '$dueTime:00' WHERE $t1_columnName1 = $id"
          );
          await db.rawUpdate(
              "UPDATE $tableName3 SET $t1_columnName6 = '$duePeriod' WHERE $t1_columnName1 = $id"
          );
      }
    }
  }

  Future editOverdueTask(int id, {String? dueDate, String? dueTime}) async {
    final db = await _instance.database;

    await db!.rawInsert(
      '''INSERT INTO $tableName1($t1_columnName1, $t1_columnName2, $t1_columnName3, $t1_columnName4, $t1_columnName5, $t1_columnName6)
      SELECT * FROM $tableName3 WHERE id = $id
      '''
      );

    await db.delete(
      tableName3, 
      where: "id = ?",
      whereArgs: [id]
    );

  }

  Future undoCompleted(int id, int tableNumber) async {
    final db = await _instance.database;

    if (tableNumber == 1) {
      await db!.rawInsert(
        '''INSERT INTO $tableName1($t1_columnName1, $t1_columnName2, $t1_columnName3, $t1_columnName4, $t1_columnName5, $t1_columnName6)
      SELECT $t2_columnName1, $t2_columnName2, $t2_columnName6, $t2_columnName7, $t2_columnName8, $t2_columnName9 FROM $tableName2 WHERE id = $id
      '''
      );
    }else{
      await db!.rawInsert(
        '''INSERT INTO $tableName3($t3_columnName1, $t3_columnName2, $t3_columnName3, $t3_columnName4, $t3_columnName5, $t3_columnName6)
      SELECT $t2_columnName1, $t2_columnName2, $t2_columnName6, $t2_columnName7, $t2_columnName8, $t2_columnName9 FROM $tableName2 WHERE id = $id
      '''
      );
    }
    await db.delete(
      tableName2,
      where: "id = ?",
      whereArgs: [id]
      );
  }
}