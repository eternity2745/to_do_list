import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:to_do_list/Database/database.dart';

class UpcomingTasks extends StatefulWidget {
  const UpcomingTasks({super.key});

  @override
  State<UpcomingTasks> createState() => _UpcomingTasksState();
}

class _UpcomingTasksState extends State<UpcomingTasks> {

  DateTime? dateTime;

  String? upcTaskName = '';
  String? upcEndDate = '';
  String? upcEndTime = '';
  String? upcperiodOfHour = '';

  String hourOfDay = "AM";
  TimeOfDay? time;
  String datePicked = "DD/MM/YY";

  List<Map<String, Object?>> result = [];

  final db = DatabaseService();

  Future getUpcomingTasks() async {
    result = await db.getUpcomingTask();
    log("$result");
    setState(() {
      
    });
  }

  @override
  void initState() {
    getUpcomingTasks();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
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
                                        "Task Name",
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
            if (result.isEmpty)...{
              Text("Nothing Here"),
            }else...{
              for (var i in result)...{        
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
                                        i['Task_Name'] as String,
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
                                          Text(i['End_Date'] as String),
                                          SizedBox(width: width*0.03,),
                                          const Icon(Icons.access_time_rounded),
                                          SizedBox(width: width*0.01,),
                                          Text(i['End_Time'] as String)
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
              }
            }
            ]
      ),
    )
      )
    );
  }
}