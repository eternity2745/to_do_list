import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/Database/database.dart';

class NavigationProvider with ChangeNotifier {
  bool persistStateUpcoming = true;
  bool persistStateLanding = true;
  bool persistStateCompleted = true;

  int noOverdueTasks = 0;
  int noCompletedTasks = 0;
  int noUpcomingTasks = 0;

  final db = DatabaseService();

  String taskName = "";
  String createdDate = "";
  String dueDate = "";
  String dueTime = "";
  String overdue = "";
  String completed = "";

  List<Map<String, Object?>> completedTasks = []; 
  List<Map<String, Object?>> upcomingTasks = [];
  List<Map<String, Object?>> overdueTasks = [];  

  void updateTaskDetails(String taskName, String createdDate, String dueDate, String dueTime, String completed, String overdue) {
    this.taskName = taskName;
    this.createdDate = createdDate;
    this.dueDate = dueDate;
    this.dueTime = dueTime;
    this.completed = completed;
    this.overdue = overdue;
    notifyListeners();
  }

  Future getUpcomingTasks() async {
    log("Upcoming Tasks Called");
    upcomingTasks = [];
    List<Map<String, Object?>> results = await db.getUpcomingTask();
    String upcEndTime = '';
    for (var i in results) {
    upcEndTime = i['End_Time'] as String;
    upcEndTime = upcEndTime.substring(0, upcEndTime.length - 3);
    int timeHour24 = int.parse(upcEndTime.substring(0, upcEndTime.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime.length == 5?upcEndTime.substring(3) : upcEndTime.substring(2)}";
    upcomingTasks.add({
      "id":i["id"], 
      "Task_Name":i["Task_Name"], 
      "Created":i["Created"], 
      "End_Date":i["End_Date"], 
      "End_Time":upcEndTime, 
      "Period_Of_Hour":i["Period_Of_Hour"],
      "Deleted" : false
      }
      );
    }
    notifyListeners();
    //log("$upcomingTasks");
  }

  //Future updateUpcomingTasks(int id, String taskName, String created, String endDate, String endTime, String periodOfHour, {bool deleted = false}) async {
  Future updateUpcomingTasks() async {
    List<Map<String, Object?>> taskDetail = await db.updateUpcomingTasks();
    //List<Map<String, Object?>> taskDetail = [for (var i in taskDetailOG) i];
    var inputFormat = DateFormat('dd/MM/yyyy');
    var outputFormat = DateFormat('yyyy-MM-dd');
    var tddateOG = inputFormat.parse(taskDetail[0]['End_Date'] as String);
    var tddate = outputFormat.format(tddateOG);
    log(tddate);
    DateTime tdDateTime = DateTime.parse("$tddate ${taskDetail[0]["End_Time"] as String}");
    log("$tdDateTime");
    int index = 0; 
    var time1 = '';
    for (var i in upcomingTasks) {
      var date1OG = inputFormat.parse(i['End_Date'] as String);
      var date1 = outputFormat.format(date1OG);
      log(date1);
      if (i["Period_Of_Hour"] as String == "AM") {
        var duptime1 = i["End_Time"] as String;
        if (duptime1.substring(0, 2) == "12") {
          time1 = "00${duptime1.substring(2)}";
        }else{
          time1 = i["End_Time"] as String;
        }
      }else{
          var duptime1 = i["End_Time"] as String;
          int time24 = int.parse(duptime1.substring(0, 2)) + 12;
          time1 = "${time24 == 24 ? time24-12 : time24}${duptime1.substring(2)}";
      }
      DateTime upcDateTime = DateTime.parse("$date1 $time1:00");
      log("$upcDateTime");

      if (tdDateTime.isBefore(upcDateTime)) {
          index = upcomingTasks.indexOf(i);
          break;
        }

    }
    String upcEndTime = taskDetail[0]['End_Time'] as String;
    upcEndTime = upcEndTime.substring(0, upcEndTime.length - 3);
    int timeHour24 = int.parse(upcEndTime.substring(0, upcEndTime.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime.length == 5?upcEndTime.substring(3) : upcEndTime.substring(2)}";
    if (index == 0) {
      upcomingTasks.add({
        "id":taskDetail[0]["id"], 
        "Task_Name":taskDetail[0]["Task_Name"], 
        "Created":taskDetail[0]["Created"], 
        "End_Date":taskDetail[0]["End_Date"], 
        "End_Time":upcEndTime, 
        "Period_Of_Hour":taskDetail[0]["Period_Of_Hour"],
        "Deleted" : false
      });
    }else{
      upcomingTasks.insert(index, 
      {
        "id":taskDetail[0]["id"], 
        "Task_Name":taskDetail[0]["Task_Name"], 
        "Created":taskDetail[0]["Created"], 
        "End_Date":taskDetail[0]["End_Date"], 
        "End_Time":upcEndTime, 
        "Period_Of_Hour":taskDetail[0]["Period_Of_Hour"],
        "Deleted" : false
      });
    }
    // Map<String, Object?> newTask = {
    //   "id":id, 
    //   "Task_Name":taskName, 
    //   "Created":created, 
    //   "End_Date":endDate, 
    //   "End_Time":endTime.substring(0, endTime.length-3),
    //   "Period_Of_Hour":periodOfHour,
    //   "Deleted" : deleted
    //   };
    // log("$upcomingTasks");
    // log("$newTask");
    // if (upcomingTasks.any((element) => element['id'] == newTask['id'])) {
    //   return false;
    // }else{
      
    // upcomingTasks.add(
    //   newTask
    // );
    // notifyListeners();
    // }
  }

  Future getOverdueTasks() async {
    List<Map<String, Object?>> results = await db.getOverdueTasks();
    String overEndTime = '';
    for (var i in results) {
    overEndTime = i['End_Time'] as String;
    overEndTime = overEndTime.substring(0, overEndTime.length - 3);
    int timeHour24 = int.parse(overEndTime.substring(0, overEndTime.length-3));
    overEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${overEndTime.length == 5?overEndTime.substring(3) : overEndTime.substring(2)}";
    overdueTasks.add({
      "id":i["id"], 
      "Task_Name":i["Task_Name"], 
      "Created":i["Created"], 
      "End_Date":i["End_Date"], 
      "End_Time":overEndTime,
      "Period_Of_Hour":i["Period_Of_Hour"],
      "Deleted" : false
      }
      );
    }
    notifyListeners();
  }

  Future updateOverDueTasks({bool? checkUpcoming = false}) async {
    log("UPDATING OVERDUE TASKS");
    List<Map<String, Object?>> update = await db.updateOverDueTasks();
    Map<String, Object?> newTask = {
      "id": int, 
      "Task_Name":'', 
      "Created":'', 
      "End_Date":'', 
      "End_Time":'',
      "Period_Of_Hour":'',
      "Deleted" : bool
      };
    log("UPDATE: $update");
    if (update.isNotEmpty) {
      String overEndTime = '';
      for (var i in update) {
        overEndTime = i['End_Time'] as String;
        overEndTime = overEndTime.substring(0, overEndTime.length - 3);
        int timeHour24 = int.parse(overEndTime.substring(0, overEndTime.length-3));
        overEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${overEndTime.length == 5?overEndTime.substring(3) : overEndTime.substring(2)}";
        newTask['id'] = i['id'];
        newTask['Task_Name'] = i['Task_Name'];
        newTask['Created'] = i['Created'];
        newTask['End_Date'] = i['End_Date'];
        newTask['End_Time'] = overEndTime;
        newTask['Period_Of_Hour'] = i['Period_Of_Hour'];
        newTask["Deleted"] = false;
        
        overdueTasks.add(newTask);
        upcomingTasks.removeWhere((element) => element['id'] == newTask['id']);
      }
      notifyListeners();
    }else if (update.isEmpty && checkUpcoming == true){
      //List<Map<String, Object?>> taskDetail = await db.updateUpcomingTasks();
      log("ONTO UPDATING UPCOMING");
      await updateUpcomingTasks();
      //getUpcomingTasks();
    }
  }


  Future getCompletedTasks() async {
    log("Completed_Task called");
    List<Map<String, Object?>> results = await db.getCompletedTasks();
    String? upcEndTime = '';
    for (var i in results) {
    upcEndTime = i['Completed_Time'] as String;
    upcEndTime = upcEndTime.substring(0, upcEndTime.length - 3);
    int timeHour24 = int.parse(upcEndTime.substring(0, upcEndTime.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime.length == 5?upcEndTime.substring(3) : upcEndTime.substring(2)}";
    completedTasks.add({
      "id":i["id"], 
      "Task_Name":i["Task_Name"], 
      "Completed_Date":i["Completed_Date"],
      "Completed_Time" : upcEndTime,
      "Completed_Period_Of_Hour" : i["Completed_Period_Of_Hour"],
      "Created":i["Created"], 
      "End_Date":i["End_Date"], 
      "End_Time":i["End_Time"], 
      "Period_Of_Hour":i["Period_Of_Hour"]
      }
      );
    }
    notifyListeners();
  }

  void updateCompletedTasks(int id, String taskName, String completedDate, String completedTime, String completedPeriodOfHour, String created, String endDate, String endTime, String periodOfHour) {
    log("UPDATING COMPLETED TASKS");
    String? comTime = '';
    comTime = completedTime;
    comTime = comTime.substring(0, comTime.length - 3);
    int timeHour24 = int.parse(comTime.substring(0, comTime.length-3));
    comTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${comTime.length == 5?comTime.substring(3) : comTime.substring(2)}";
    completedTasks.add({
      "id":id, 
      "Task_Name":taskName, 
      "Completed_Date":completedDate,
      "Completed_Time" : comTime,
      "Completed_Period_Of_Hour" : completedPeriodOfHour,
      "Created":created, 
      "End_Date":endDate, 
      "End_Time": endTime, 
      "Period_Of_Hour":periodOfHour
    });
    notifyListeners();
    log("UPDATED AND NOTIFIED");
  }

  Future getStatistics() async {
    List statistics = await db.getStatistics();
    noUpcomingTasks = statistics[0];
    noCompletedTasks = statistics[1];
    noOverdueTasks = statistics[2];
  }

  void changenoOverdueTasks(int number) {
    noOverdueTasks = number;
    notifyListeners();
  }

  void changenoCompletedTasks(int number) {
    noCompletedTasks = number;
    notifyListeners();
  }

  void changenoUpcomingTasks(int number) {
    noUpcomingTasks = number;
    notifyListeners();
  }

  void changePersistStateUpcoming(bool state) {
    persistStateUpcoming = state;
    notifyListeners();
  }

  void changePersistStateLanding(bool state) {
    persistStateLanding = state;
    notifyListeners();
  }

  void changePersistStateCompleted(bool state) {
    persistStateCompleted = state;
    notifyListeners();
  }
}