import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/Database/database.dart';

class NavigationProvider with ChangeNotifier {
  bool persistStateUpcoming = true;
  bool persistStateLanding = true;
  bool persistStateCompleted = true;

  bool callbackPossible = true;

  int noOverdueTasks = 0;
  int noCompletedTasks = 0;
  int noUpcomingTasks = 0;

  int selectedIndex = 0;
  String selectedTaskType = '';
  int selectedTaskID = 0;

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

  String upcomingTask = "";
  String upcomingCreated = "";
  String upcomingEndDate = "";
  String upcomingEndTime = "";
  String upcomingPeriodOfHour = "";

  void updateUpcomingTask(String upcomingTask, String upcomingCreated, String upcomingEndDate, String upcomingEndTime, String upcomingPeriodOfHour, bool notify) {
    this.upcomingTask = upcomingTask;
    this.upcomingCreated = upcomingCreated;
    this.upcomingEndDate = upcomingEndDate;
    this.upcomingEndTime = upcomingEndTime;
    this.upcomingPeriodOfHour = upcomingPeriodOfHour;
    if (notify) {
      notifyListeners();
    }
  }

  void updateTaskDetails(String taskName, String createdDate, String dueDate, String dueTime, String completed, String overdue, int selectedIndex, String selectedTaskType, int selectedTaskID) {
    this.taskName = taskName;
    this.createdDate = createdDate;
    this.dueDate = dueDate;
    this.dueTime = dueTime;
    this.completed = completed;
    this.overdue = overdue;
    this.selectedIndex = selectedIndex;
    this.selectedTaskType = selectedTaskType;
    this.selectedTaskID = selectedTaskID;
    notifyListeners();
  }

  void editTaskDetails({String? dueDate, String? dueTime, bool? notify = true}) {
    if (dueDate != null) {
      this.dueDate = dueDate;
    }

    if (dueTime != null) {
      this.dueTime = dueTime;
    }
    
    if (notify!) {
      notifyListeners();
    }
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

  Future updateEditOverdueTasks(int selctedIndex, Map<String, Object?> task, bool isDueDate) async {

    List<Map<String, Object?>> taskDetail = [task];
    var inputFormat = DateFormat('dd/MM/yyyy');
    var outputFormat = DateFormat('yyyy-MM-dd');
    var tddateOG = inputFormat.parse(taskDetail[0]['End_Date'] as String);
    var tddate = outputFormat.format(tddateOG);
    log(tddate);
    DateTime tdDateTime = DateTime.parse("$tddate ${taskDetail[0]["End_Time"] as String}");
    if(tdDateTime.isAfter(DateTime.now())) {
      if (isDueDate) {
        await db.editTask(taskDetail[0]["id"] as int, 3, dueDate: taskDetail[0]["End_Date"] as String);
      }else{
        await db.editTask(taskDetail[0]["id"] as int, 3, dueTime: taskDetail[0]["End_Time"] as String, duePeriod: taskDetail[0]["Period_Of_Hour"] as String);
      }
      updateUpcomingTasks(task: task, selectedIndex: selctedIndex, updateOverdue: true);
      return;
    }
    log("$tdDateTime");
    int index = 0; 
    bool checkIndex = false;
    var time1 = '';

    for (var i in overdueTasks) {
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
      DateTime ovrdDateTime = DateTime.parse("$date1 $time1:00");
      log("$ovrdDateTime");

      if (tdDateTime.isBefore(ovrdDateTime)) {
          index = overdueTasks.indexOf(i);
          checkIndex = true;
          break;
        }
    }

    log("INDEX: $index");
    if (index == 0 && checkIndex == false) {
      overdueTasks.add({
        "id":taskDetail[0]["id"], 
        "Task_Name":taskDetail[0]["Task_Name"], 
        "Created":taskDetail[0]["Created"], 
        "End_Date":taskDetail[0]["End_Date"], 
        "End_Time":taskDetail[0]['End_Time'] as String, 
        "Period_Of_Hour":taskDetail[0]["Period_Of_Hour"],
        "Deleted" : false
      });
    }else{
      overdueTasks.insert(index, 
      {
        "id":taskDetail[0]["id"], 
        "Task_Name":taskDetail[0]["Task_Name"], 
        "Created":taskDetail[0]["Created"], 
        "End_Date":taskDetail[0]["End_Date"], 
        "End_Time":taskDetail[0]['End_Time'] as String, 
        "Period_Of_Hour":taskDetail[0]["Period_Of_Hour"],
        "Deleted" : false
      });
    }
    await db.editTask(taskDetail[0]["id"] as int, 3, dueDate: taskDetail[0]["End_Date"] as String);
    notifyListeners();
  }
  //Future updateUpcomingTasks(int id, String taskName, String created, String endDate, String endTime, String periodOfHour, {bool deleted = false}) async {
  Future updateUpcomingTasks({Map<String, Object?>? task, bool? updateOverdue = false, int? selectedIndex}) async {
    List<Map<String, Object?>> taskDetail = [];
    if(task == null) {
      taskDetail = await db.updateUpcomingTasks();
    }else{
      taskDetail.add(task);
      log("$taskDetail");
    }

    //List<Map<String, Object?>> taskDetail = [for (var i in taskDetailOG) i];
    var inputFormat = DateFormat('dd/MM/yyyy');
    var outputFormat = DateFormat('yyyy-MM-dd');
    var tddateOG = inputFormat.parse(taskDetail[0]['End_Date'] as String);
    var tddate = outputFormat.format(tddateOG);
    log(tddate);
    DateTime tdDateTime = DateTime.parse("$tddate ${taskDetail[0]["End_Time"] as String}");
    log("$tdDateTime");
    int index = 0; 
    bool checkIndex = false;
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
          checkIndex = true;
          break;
        }

    }
    String upcEndTime = taskDetail[0]['End_Time'] as String;
    log(upcEndTime);
    if (task == null) {
      upcEndTime = upcEndTime.substring(0, upcEndTime.length - 3);
      int timeHour24 = int.parse(upcEndTime.substring(0, upcEndTime.length-3));
      upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime.length == 5?upcEndTime.substring(3) : upcEndTime.substring(2)}";
    }
    log("INDEX: $index");
    if (index == 0 && checkIndex == false) {
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
    if (task != null) {
      updateUpcomingTask(upcomingTasks[0]['Task_Name'] as String, upcomingTasks[0]['Created'] as String, upcomingTasks[0]['End_Date'] as String, upcomingTasks[0]['End_Time'] as String, upcomingTasks[0]['Period_Of_Hour'] as String, false);
    }

    changenoUpcomingTasks(upcomingTasks.length, notify: false);

    if (updateOverdue!) {
      log('$overdueTasks');
      overdueTasks.removeAt(selectedIndex!);
      await db.editOverdueTask(taskDetail[0]["id"] as int);
      changenoOverdueTasks(overdueTasks.length, notify: false);
    }
    notifyListeners();
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
    log("UPDATE: $update");
    if (update.isNotEmpty) {
      String overEndTime = '';
      var inputFormat = DateFormat('dd/MM/yyyy');
      var outputFormat = DateFormat('yyyy-MM-dd');
      for (var i in update) {

        var tddateOG = inputFormat.parse(i['End_Date'] as String);
        var tddate = outputFormat.format(tddateOG);
        log(tddate);
        DateTime tdDateTime = DateTime.parse("$tddate ${i["End_Time"] as String}");
        log("$tdDateTime");
        int index = 0; 
        bool checkIndex = false;
        var time1 = '';
        for (var j in overdueTasks) {
          var date1OG = inputFormat.parse(j['End_Date'] as String);
          var date1 = outputFormat.format(date1OG);
          log(date1);
          if (j["Period_Of_Hour"] as String == "AM") {
            var duptime1 = j["End_Time"] as String;
            if (duptime1.substring(0, 2) == "12") {
              time1 = "00${duptime1.substring(2)}";
            }else{
              time1 = j["End_Time"] as String;
            }
          }else{
              var duptime1 = j["End_Time"] as String;
              int time24 = int.parse(duptime1.substring(0, 2)) + 12;
              time1 = "${time24 == 24 ? time24-12 : time24}${duptime1.substring(2)}";
          }
          DateTime ovrdDateTime = DateTime.parse("$date1 $time1:00");
          log("$ovrdDateTime");

          if (tdDateTime.isBefore(ovrdDateTime)) {
              index = overdueTasks.indexOf(j);
              checkIndex = true;
              break;
            }
        }
        overEndTime = i['End_Time'] as String;
        overEndTime = overEndTime.substring(0, overEndTime.length - 3);
        int timeHour24 = int.parse(overEndTime.substring(0, overEndTime.length-3));
        overEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${overEndTime.length == 5?overEndTime.substring(3) : overEndTime.substring(2)}";
        log("INDEX: $index");
        if (index == 0 && checkIndex == false) {
          overdueTasks.add({
            "id": i['id'], 
            "Task_Name": i['Task_Name'], 
            "Created": i['Created'], 
            "End_Date": i['End_Date'], 
            "End_Time": overEndTime,
            "Period_Of_Hour": i['Period_Of_Hour'],
            "Deleted" : false
        });
        }else{
          overdueTasks.insert(index,
          { 
            "id": i['id'], 
            "Task_Name": i['Task_Name'], 
            "Created": i['Created'], 
            "End_Date": i['End_Date'], 
            "End_Time": overEndTime,
            "Period_Of_Hour": i['Period_Of_Hour'],
            "Deleted" : false
          });
        }
        upcomingTasks.removeWhere((element) => element['id'] == i['id']);
        changenoOverdueTasks(overdueTasks.length, notify: false);
        changenoUpcomingTasks(upcomingTasks.length, notify: false);
        
      }
      if (upcomingTasks.isNotEmpty) {
      updateUpcomingTask(upcomingTasks[0]['Task_Name'] as String, upcomingTasks[0]['Created'] as String, upcomingTasks[0]["End_Date"] as String, upcomingTasks[0]["End_Time"] as String, upcomingTasks[0]["Period_Of_Hour"] as String, false);
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
    completedTasks.insert(0, {
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

  Future deleteUpcTask() async {
    await db.deleteUpcomingTask(selectedTaskID);
    upcomingTasks.removeAt(selectedIndex);
    if (upcomingTasks.isNotEmpty) {
    updateUpcomingTask(upcomingTasks[0]['Task_Name'] as String, upcomingTasks[0]['Created'] as String, upcomingTasks[0]['End_Date'] as String, upcomingTasks[0]['End_Time'] as String, upcomingTasks[0]['Period_Of_Hour'] as String, false);
    }
    changenoUpcomingTasks(upcomingTasks.length, notify: false);
    notifyListeners();
  }

  Future deleteOvrdTask() async {
    await db.deleteOverdueTask(selectedTaskID);
    overdueTasks.removeAt(selectedIndex);
    if (overdueTasks.isNotEmpty) {
    //updateUpcomingTask(overdueTasks[0]['Task_Name'] as String, overdueTasks[0]['Created'] as String, overdueTasks[0]['End_Date'] as String, overdueTasks[0]['End_Time'] as String, overdueTasks[0]['Period_Of_Hour'] as String, false);
    }
    changenoOverdueTasks(overdueTasks.length, notify: false);
    notifyListeners();
  }

  Future deleteCompTask() async {
    await db.deleteCompletedTask(selectedTaskID);
    completedTasks.removeAt(selectedIndex);
    if (completedTasks.isNotEmpty) {
    //updateUpcomingTask(completedTasks[0]['Task_Name'] as String, completedTasks[0]['Created'] as String, completedTasks[0]['End_Date'] as String, completedTasks[0]['End_Time'] as String, completedTasks[0]['Period_Of_Hour'] as String, false);
    }
    changenoCompletedTasks(completedTasks.length, notify: false);
    notifyListeners();
  }

  Future getStatistics() async {
    List statistics = await db.getStatistics();
    noUpcomingTasks = statistics[0];
    noCompletedTasks = statistics[1];
    noOverdueTasks = statistics[2];
    notifyListeners();
  }

  Future undoCompleted(selectedIndex, Map<String, Object?>taskDetails) async {
    var inputFormat = DateFormat('dd/MM/yyyy');
    var outputFormat = DateFormat('yyyy-MM-dd');
    var tddateOG = inputFormat.parse(taskDetails['End_Date'] as String);
    var tddate = outputFormat.format(tddateOG);
    log(tddate);
    int tableNumber = 0;
    DateTime tdDateTime = DateTime.parse("$tddate ${taskDetails["End_Time"] as String}");
    if (tdDateTime.isBefore(DateTime.now()) || tdDateTime.isAtSameMomentAs(DateTime.now()) ) {
      tableNumber = 3;
      updateEditOverdueTasks(0, taskDetails, false);
      changenoOverdueTasks(noOverdueTasks+1);
    }else{
      tableNumber = 1;
      updateUpcomingTasks(task: taskDetails);
    }

    await db.undoCompleted(taskDetails['id'] as int, tableNumber);
    completedTasks.removeAt(selectedIndex);
    changenoCompletedTasks(completedTasks.length);
  }

  void changenoOverdueTasks(int number, {bool notify = true}) {
    noOverdueTasks = number;
    if (notify) {
    notifyListeners();
    }
  }

  void changenoCompletedTasks(int number, {bool notify = true}) {
    noCompletedTasks = number;
    if (notify) {
    notifyListeners();
    }
  }

  void changenoUpcomingTasks(int number,{bool notify = true}) {
    noUpcomingTasks = number;
    if (notify) {
    notifyListeners();
    }
  }

  void changeCallbackPossible(bool possible) {
    callbackPossible = possible;
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