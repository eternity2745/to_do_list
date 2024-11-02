import 'dart:developer';
import 'package:sqflite/sqflite.dart';
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
              $t1_columnName5 TIME NOT NULL
              )
      ''');

      db.execute('''
              CREATE TABLE $tableName2 (
              $t2_columnName1 INT NOT NULL,
              $t2_columnName2 DATE NOT NULL,
              $t2_columnName3 TIME NOT NULL,
              FOREIGN KEY (id) REFERENCES Upcoming(id)
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

  Future<void> createTask(String taskName, String date, String time) async {

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
        t1_columnName4: date,
        t1_columnName5: "$time:00"
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

}