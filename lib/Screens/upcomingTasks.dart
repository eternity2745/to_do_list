import 'dart:async';
import 'dart:developer';
import 'dart:math' as mathematics;
import 'package:animate_icons/animate_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Database/database.dart';
import 'package:to_do_list/Providers/navProvider.dart';
import 'package:to_do_list/Screens/taskDetails.dart';

// ignore: must_be_immutable
class UpcomingTasks extends StatefulWidget {
  UpcomingTasks({super.key, required this.isPersistState});

  bool isPersistState;

  @override
  State<UpcomingTasks> createState() => _UpcomingTasksState();
}

class _UpcomingTasksState extends State<UpcomingTasks> with AutomaticKeepAliveClientMixin{

  DateTime? dateTime;

  AnimateIconController animateIconController = AnimateIconController(); 
  final ConfettiController _controllerBottomCenter = ConfettiController(duration: Duration(milliseconds: 350));

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
      "Period_Of_Hour":i["Period_Of_Hour"],
      "Deleted" : false
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
      "Period_Of_Hour":i["Period_Of_Hour"],
      "Deleted" : false
      }
      );
    }
    log("HEHEHEHEHEH\n$overdueTasks");
    setState(() {
      
    });
  }

  Future updateOverDueTasks() async {
    bool update = await db.updateOverDueTasks();
    if (update) {
    getOverdueTasks();
    }
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
    updateOverDueTasks();
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
      extendBody: true,
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
              log("REBUILD OVERDUE BUILDER");
              return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: overdueTasks.length,
              itemBuilder: (BuildContext context, int index) {                              
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).updateTaskDetails(overdueTasks[index]['Task_Name'] as String, overdueTasks[index]['Created'] as String, overdueTasks[index]['End_Date'] as String, "${overdueTasks[index]['End_Time']} ${overdueTasks[index]['Period_Of_Hour']}", "No", "Yes");
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetails()));
                    },
                    child: Container(
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
                                        int noCompletedTasks = Provider.of<NavigationProvider>(context, listen: false).noCompletedTasks;
                                        int noOverdueTasks = Provider.of<NavigationProvider>(context, listen: false).noOverdueTasks;
                                        log("COMPLETED $noCompletedTasks");
                                        log("OVERDUE $noOverdueTasks");
                                        Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                        Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(noCompletedTasks+1);
                                        Provider.of<NavigationProvider>(context, listen: false).changenoOverdueTasks(noOverdueTasks-1);
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
              log("REBUILD UPCOMING BUILDER");
              return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: upcomingTasks.length,
              itemBuilder: (BuildContext context, int index) {                              
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false).updateTaskDetails(upcomingTasks[index]['Task_Name'] as String, upcomingTasks[index]['Created'] as String, upcomingTasks[index]['End_Date'] as String, "${upcomingTasks[index]['End_Time']} ${upcomingTasks[index]['Period_Of_Hour']}", "No", "No");
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetails()));
                    },
                    child: Container(
                      height: height*0.1,
                      width: width*0.9,
                      decoration: BoxDecoration(
                        color: upcomingTasks[index]["Deleted"] as bool? Colors.grey.shade900 : Colors.blueGrey.shade900,
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
                                    icon: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 350),
                                        transitionBuilder: (child, anim) => RotationTransition(
                                              turns: child.key == ValueKey('icon1')
                                                  ? Tween<double>(begin: 1, end: 0).animate(anim)
                                                  : Tween<double>(begin: 1, end: 1).animate(anim),
                                              child: SizeTransition(sizeFactor: anim, child: child),
                                            ),
                                        child: upcomingTasks[index]["Deleted"] as bool
                                            ? Icon(Icons.check_circle_outline_rounded, key: const ValueKey('icon1'))
                                            : Icon(
                                                Icons.check_box_outline_blank_rounded,
                                                key: const ValueKey('icon2'),
                                                
                                              )),
                                        onPressed: () {
                                          upcomingTasks[index]["Deleted"] = true;
                                        log("${_controllerBottomCenter.state}");
                                        _controllerBottomCenter.play();
                                        int noCompletedTasks = Provider.of<NavigationProvider>(context, listen: false).noCompletedTasks;
                                        int noUpcomingTasks = Provider.of<NavigationProvider>(context, listen: false).noUpcomingTasks;
                                        Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                        Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(noCompletedTasks+1);
                                        Provider.of<NavigationProvider>(context, listen: false).changenoUpcomingTasks(noUpcomingTasks-1);
                                        Timer(Duration(milliseconds: 250), () {  
                                            upcomingTasks.removeAt(index);
                                            
                                        });
                                        Timer(Duration(milliseconds: 1000), () {
                                          setState(() {
                                            
                                          });
                                        });
                                        
                                        }
                                  ),
                                  // AnimateIcons(
                                  //   controller: animateIconController,
                                  //   startIcon: Icons.check_box_outline_blank_rounded,
                                  //   endIcon: upcomingTasks[index]["Deleted"] as bool ? Icons.check_circle_outline_rounded : Icons.check_box_outline_blank_rounded,
                                  //   startIconColor: Colors.white,
                                  //   endIconColor: Colors.green,
                                  //   duration: Duration(milliseconds: 500),
                                  //   onStartIconPress: () {
                                  //       //completeTasks(upcomingTasks[index], 1);
                                  //       animateIconController.animateToStart();
                                  //       upcomingTasks[index]["Deleted"] = true;
                                  //       _controllerBottomCenter.play();
                                  //       int noCompletedTasks = Provider.of<NavigationProvider>(context, listen: false).noCompletedTasks;
                                  //       int noUpcomingTasks = Provider.of<NavigationProvider>(context, listen: false).noUpcomingTasks;
                                  //       Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                  //       Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(noCompletedTasks+1);
                                  //       Provider.of<NavigationProvider>(context, listen: false).changenoUpcomingTasks(noUpcomingTasks-1);
                                  //       Timer(Duration(seconds: 1), () {upcomingTasks.removeAt(index);});
                                  //       return true;
                                  //   }, 
                                  //   onEndIconPress: () {
                                  //     return false;
                                  //   },
                                  //   ),
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
                                                fontSize: height*0.025,
                                                decoration: upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none
                                              ),
                                              overflow: TextOverflow.ellipsis,                         
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_month_outlined),
                                                SizedBox(width: width*0.01,),
                                                Text(upcomingTasks[index]['End_Date'] as String, 
                                                    style: TextStyle(
                                                      decoration: upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
                                                      ),
                                                SizedBox(width: width*0.03,),
                                                const Icon(Icons.access_time_rounded),
                                                SizedBox(width: width*0.01,),
                                                Text("${upcomingTasks[index]['End_Time'] as String} ${upcomingTasks[index]['Period_Of_Hour'] as String}",
                                                    style: TextStyle(
                                                      decoration: upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
                                                      ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _controllerBottomCenter,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.01,
              numberOfParticles: 50,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
            )
          )
        ]
      ),
    )
      )
    );
  }
}