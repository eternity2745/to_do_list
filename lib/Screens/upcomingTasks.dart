import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Database/database.dart';
import 'package:to_do_list/Providers/navProvider.dart';

// ignore: must_be_immutable
class UpcomingTasks extends StatefulWidget {
  UpcomingTasks({super.key, required this.isPersistState});

  bool isPersistState;

  @override
  State<UpcomingTasks> createState() => _UpcomingTasksState();
}

class _UpcomingTasksState extends State<UpcomingTasks> with AutomaticKeepAliveClientMixin{

  DateTime? dateTime;

  String? upcTaskName = '';
  String? upcEndDate = '';
  String? upcEndTime = '';
  String? upcperiodOfHour = '';

  String? overEndTime = '';

  String hourOfDay = "AM";
  TimeOfDay? time;
  String datePicked = "DD/MM/YY";

  String overdueTaskName = "Task Name";

  List<Map<String, Object?>> upcomingTasks = [];
  List<Map<String, Object?>> overdueTasks = [];

  bool persistState = true;

  final db = DatabaseService();

  Future getUpcomingTasks() async {
    List<Map<String, Object?>> results = await db.getUpcomingTask();
    for (var i in results) {
    upcEndTime = i['End_Time'] as String;
    upcEndTime = upcEndTime!.substring(0, upcEndTime!.length - 3);
    int timeHour24 = int.parse(upcEndTime!.substring(0, upcEndTime!.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime!.length == 5?upcEndTime!.substring(3) : upcEndTime!.substring(2)}";
    upcomingTasks.add({
      "id":i["id"], 
      "Task_Name":i["Task_Name"], 
      "Created":i["Created"], 
      "End_Date":i["End_Date"], 
      "End_Time":upcEndTime, 
      "Period_Of_Hour":i["Period_Of_Hour"]
      }
      );
    }
    //log("$upcomingTasks");

  }

  Future getOverdueTasks() async {
    List<Map<String, Object?>> results = await db.getOverdueTasks();
    for (var i in results) {
    overEndTime = i['End_Time'] as String;
    overEndTime = overEndTime!.substring(0, overEndTime!.length - 3);
    int timeHour24 = int.parse(overEndTime!.substring(0, overEndTime!.length-3));
    overEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${overEndTime!.length == 5?overEndTime!.substring(3) : overEndTime!.substring(2)}";
    overdueTasks.add({
      "id":i["id"], 
      "Task_Name":i["Task_Name"], 
      "Created":i["Created"], 
      "End_Date":i["End_Date"], 
      "End_Time":overEndTime,
      "Period_Of_Hour":i["Period_Of_Hour"]
      }
      );
    }
    log("HEHEHEHEHEH\n$overdueTasks");
    setState(() {
      
    });
  }

  Future deleteTask(int id, int tableNumber) async {
    await db.deleteTask(id, tableNumber);
    log("DELETED");
  }

  Future completeTasks(Map<String, Object?> details, int tableNumber) async {
    log("DETAILS: $details");
    DateTime dateTime = DateTime.now();
    String periodOfHour = dateTime.hour < 12 ? "AM" : "PM";
    String time = "${dateTime.hour < 10 && dateTime.hour > 0 ? '0${dateTime.hour}' : dateTime.hour == 0 ? '00' : dateTime.hour}:${dateTime.minute == 0 ? '00' : dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute}:00";
    String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    details['Completed_Time'] = time;
    details['Completed_Date'] = date;
    details['Completed_Period_Of_Hour'] = periodOfHour;

    db.completeTask(details, tableNumber);

    log("Completed");
  }

  @override
  void initState() {
    getUpcomingTasks();
    getOverdueTasks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  bool get wantKeepAlive => persistState;

  @override
  Widget build(BuildContext context) {
    persistState = Provider.of<NavigationProvider>(context).persistStateUpcoming;
    updateKeepAlive();
    if (wantKeepAlive) {
      super.build(context);
    }
    log("$wantKeepAlive");
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
        "Upcoming Tasks",
        style: TextStyle(
            fontSize: height/25,
            fontWeight: FontWeight.bold
          ),
      ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height*0.03, horizontal: width*0.08),
          child: Column(
            children: [
              Text(
                "Overdue",
                style: TextStyle(
                  fontSize: height*0.04,
                  fontWeight: FontWeight.w500
                ),
                ),
              SizedBox(height: height*0.008,),
              if (overdueTasks.isEmpty)...{
              Text("Nothing Here"),
            }else...{
              StatefulBuilder(builder: (BuildContext context , setState) {
              return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: overdueTasks.length,
              itemBuilder: (BuildContext context, int index) {                              
              return Column(
                children: [
                  Container(
                    height: height*0.1,
                    width: width*0.9,
                    decoration: BoxDecoration(
                      color: Colors.red.shade800,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height*0.008, horizontal: width*0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      completeTasks(overdueTasks[index], 3);
                                      overdueTasks.removeAt(index);
                                      Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                    });
                                  },
                                  icon: const Icon(Icons.check_box_outline_blank_rounded)
                                  ),
                                  SizedBox(width: width*0.01),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: height*0.008, bottom: height*0.01),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                            overdueTasks[index]['Task_Name'] as String,
                                            style: TextStyle(
                                              fontSize: height*0.025
                                            ),
                                            overflow: TextOverflow.ellipsis,                         
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_month_outlined),
                                              SizedBox(width: width*0.01,),
                                              Text(overdueTasks[index]['End_Date'] as String),
                                              SizedBox(width: width*0.03,),
                                              const Icon(Icons.access_time_rounded),
                                              SizedBox(width: width*0.01,),
                                              Text("${overdueTasks[index]['End_Time'] as String} ${overdueTasks[index]['Period_Of_Hour'] as String}")
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height*0.01,)
                ],
              );
              }
              );
              }
              )
          },
            Text(
                "Pending",
                style: TextStyle(
                  fontSize: height*0.04,
                  fontWeight: FontWeight.w500
                ),
              ),
            SizedBox(height: height*0.008,),
            if (upcomingTasks.isEmpty)...{
              Text("Nothing Here"),
            }else...{
              StatefulBuilder(builder: (BuildContext context , setState) {
              return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: upcomingTasks.length,
              itemBuilder: (BuildContext context, int index) {                              
              return Column(
                children: [
                  Container(
                    height: height*0.1,
                    width: width*0.9,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height*0.008, horizontal: width*0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      completeTasks(upcomingTasks[index], 1);
                                      upcomingTasks.removeAt(index);
                                      Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                    });
                                  }, 
                                  icon: const Icon(Icons.check_box_outline_blank_rounded)
                                  ),
                                  SizedBox(width: width*0.01),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: height*0.008, bottom: height*0.01),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                            upcomingTasks[index]['Task_Name'] as String,
                                            style: TextStyle(
                                              fontSize: height*0.025
                                            ),
                                            overflow: TextOverflow.ellipsis,                         
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_month_outlined),
                                              SizedBox(width: width*0.01,),
                                              Text(upcomingTasks[index]['End_Date'] as String),
                                              SizedBox(width: width*0.03,),
                                              const Icon(Icons.access_time_rounded),
                                              SizedBox(width: width*0.01,),
                                              Text("${upcomingTasks[index]['End_Time'] as String} ${upcomingTasks[index]['Period_Of_Hour'] as String}")
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height*0.01,)
                ],
              );
              }
              );
              }
              )
          }
            ]
      ),
    )
      )
    );
  }
}