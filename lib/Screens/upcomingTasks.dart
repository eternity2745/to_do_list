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

  String hourOfDay = "AM";
  TimeOfDay? time;
  String datePicked = "DD/MM/YY";

  String overdueTaskName = "Task Name";

  List<Map<String, Object?>> upcomingTasks = [];   

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
    log("$upcomingTasks");
    setState(() {
      
    });
  }

  Future getOverdueTasks() async {
    
  }

  Future deleteTask(int id) async {
    await db.deleteTask(id);
    log("DELETED");
  }

  @override
  void initState() {
    getUpcomingTasks();
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
    persistState = Provider.of<NavigationProvider>(context).persistState;
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
              Container(
                height: height*0.1,
                width: width*0.9,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
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
                              onPressed: () {}, 
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
                                        overdueTaskName,
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
                                          Text("End Date"),
                                          SizedBox(width: width*0.03,),
                                          const Icon(Icons.access_time_rounded),
                                          SizedBox(width: width*0.01,),
                                          Text("End Time")
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
            SizedBox(height: height*0.03,),
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
                                      deleteTask(upcomingTasks[index]['id'] as int);
                                      upcomingTasks.removeAt(index);
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