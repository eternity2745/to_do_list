import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Database/database.dart';
import 'package:to_do_list/Providers/navProvider.dart';
import 'package:to_do_list/Screens/taskDetails.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> with AutomaticKeepAliveClientMixin {

  bool persistState = true;

  final db = DatabaseService();

  List<Map<String, Object?>> completedTasks = [];

  Future getCompletedTasks() async {
    List<Map<String, Object?>> results = await db.getCompletedTasks();
    log("RESULT:\n$results");
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
    setState(() {
      
    });
    log("COMPLETED TASKS:\n$completedTasks");
  }

  @override
  bool get wantKeepAlive => persistState;

  @override
  void initState() {
    getCompletedTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    persistState = Provider.of<NavigationProvider>(context).persistStateCompleted;
    updateKeepAlive();
    if (wantKeepAlive) {
      super.build(context);
    }

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(
          "Completed Tasks",
          style: TextStyle(
              fontSize: height/25,
              fontWeight: FontWeight.bold
            ),
        ),
      ),
        extendBody: true,
        body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height*0.03, horizontal: width*0.08),
          child: Column(
            children: [
              Text(
                "Completed",
                style: TextStyle(
                  fontSize: height*0.04,
                  fontWeight: FontWeight.w500
                ),
                ),
              SizedBox(height: height*0.008,),
              if (completedTasks.isEmpty)...{
              Text("Nothing Here"),
            }else...{
              StatefulBuilder(builder: (BuildContext context , setState) {
                log("ENTERED STATEFUL");
              return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: completedTasks.length,
              itemBuilder: (BuildContext context, int index) {
                log("ENTERED BUILDER: ${completedTasks.length}");                              
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).updateTaskDetails(completedTasks[index]['Task_Name'] as String, completedTasks[index]['Created'] as String, completedTasks[index]['End_Date'] as String, "${completedTasks[index]['End_Time']} ${completedTasks[index]['Period_Of_Hour']}", "Yes", "No");
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetails()));
                    },
                    child: Container(
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
                                      // setState(() {
                                      //   deleteTask(completedTasks[index]['id'] as int, 3);
                                      //   completedTasks.removeAt(index);
                                      // });
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
                                              completedTasks[index]['Task_Name'] as String,
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
                                                Text(completedTasks[index]['Completed_Date'] as String),
                                                SizedBox(width: width*0.03,),
                                                const Icon(Icons.access_time_rounded),
                                                SizedBox(width: width*0.01,),
                                                Text("${completedTasks[index]['Completed_Time'] as String} ${completedTasks[index]['Completed_Period_Of_Hour'] as String}")
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
                  ),
                  SizedBox(height: height*0.01,)
                ],
              );
              }
              );
              }
              )
          },
            ]
          )
        )
      )
    );
  }
}