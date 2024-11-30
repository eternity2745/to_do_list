import 'dart:async';
import 'dart:developer';
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
    String endTime = details["End_Time"] as String;
    if (details["Period_Of_Hour"] == "AM") {
      endTime = "${endTime.substring(0,2) == "12" ? "00" : endTime.substring(0,2)}${endTime.substring(2)}:00";
    }else{
      endTime = "${int.parse(endTime.substring(0,2))+12}${endTime.substring(2)}:00";
    }
    details["End_Time"] = endTime;
    Map<String, Object?> detailsReplica = { for (var e in details.keys) e : details[e] };
    Provider.of<NavigationProvider>(context, listen: false).updateCompletedTasks(details['id'] as int, details['Task_Name'] as String, details['Completed_Date'] as String, details['Completed_Time'] as String, details['Completed_Period_Of_Hour'] as String, details['Created'] as String, details['End_Date'] as String, details['End_Time'] as String, details['Period_Of_Hour'] as String);
    await db.completeTask(detailsReplica, tableNumber);
  }

  @override
  void initState() {
    //getUpcomingTasks();
    //getOverdueTasks();
    super.initState();
  }

  @override
  void dispose() {
    _controllerBottomCenter.dispose();
    super.dispose();
  }


  @override
  bool get wantKeepAlive => persistState;

  @override
  Widget build(BuildContext context) {
    persistState = Provider.of<NavigationProvider>(context).persistStateUpcoming;
    //updateKeepAlive();

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
              StatefulBuilder(builder: (BuildContext context , setState) {
              if (Provider.of<NavigationProvider>(context, listen: false).overdueTasks.isEmpty){
                  return Text("Nothing Here");
              }else{
              log("REBUILD OVERDUE BUILDER");
              return Consumer<NavigationProvider>(
                builder: (context, value, child) {
                return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: value.overdueTasks.length,
                itemBuilder: (BuildContext context, int index) {                              
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        String endTime = value.overdueTasks[index]['End_Time'] as String;
                        int hour = int.parse(endTime.substring(0,2));
                        int minute = int.parse(endTime.substring(3,5));
                        endTime = "${hour == 0 ? 12 : hour > 12 ? (hour-12) < 10 ? '0${hour-12}' : hour-12 : hour < 10 ? '0$hour' : hour}:${minute == 0 ? '00' : minute < 10 ? '0$minute' : minute}";
                        if(Provider.of<NavigationProvider>(context, listen: false).callbackPossible) {
                          Provider.of<NavigationProvider>(context, listen: false).updateTaskDetails(value.overdueTasks[index]['Task_Name'] as String, value.overdueTasks[index]['Created'] as String, value.overdueTasks[index]['End_Date'] as String, "$endTime ${value.overdueTasks[index]['Period_Of_Hour']}", "No", "Yes", index, "Overdue", value.overdueTasks[index]['id'] as int);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetails()));
                        }
                      },
                      child: Container(
                        height: height*0.1,
                        width: width*0.9,
                        decoration: BoxDecoration(
                          color: value.overdueTasks[index]["Deleted"] as bool? Colors.green.shade800 : Colors.red.shade800,
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
                                          Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(false);
                                          _controllerBottomCenter.play();
                                          value.overdueTasks[index]["Deleted"] = true;
                                          completeTasks(value.overdueTasks[index], 3);
                                          log("${_controllerBottomCenter.state}");
                                          int noCompletedTasks = Provider.of<NavigationProvider>(context, listen: false).noCompletedTasks;
                                          int noOverdueTasks = Provider.of<NavigationProvider>(context, listen: false).noOverdueTasks;
                                          //Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                          Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(noCompletedTasks+1);
                                          Provider.of<NavigationProvider>(context, listen: false).changenoOverdueTasks(noOverdueTasks-1);
                                          
                                          Timer(Duration(milliseconds: 250), () {  
                                              value.overdueTasks.removeAt(index);
                                              Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(true);
                                          });
                                          Timer(Duration(milliseconds: 1000), () {
                                            setState(() {
                                              
                                            });
                                          });
                                      },
                                      icon: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 350),
                                          transitionBuilder: (child, anim) => RotationTransition(
                                                turns: child.key == ValueKey('icon3')
                                                    ? Tween<double>(begin: 1, end: 0).animate(anim)
                                                    : Tween<double>(begin: 1, end: 1).animate(anim),
                                                child: SizeTransition(sizeFactor: anim, child: child),
                                              ),
                                          child: value.overdueTasks[index]["Deleted"] as bool
                                              ? Icon(Icons.check_circle_outline_rounded, key: const ValueKey('icon3'))
                                              : Icon(
                                                  Icons.check_box_outline_blank_rounded,
                                                  key: const ValueKey('icon4'),
                                                  
                                                )),
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
                                                value.overdueTasks[index]['Task_Name'] as String,
                                                style: TextStyle(
                                                  fontSize: height*0.025,
                                                  decoration: value.overdueTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none
                                                ),
                                                overflow: TextOverflow.ellipsis,                         
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_month_outlined),
                                                  SizedBox(width: width*0.01,),
                                                  Text(value.overdueTasks[index]['End_Date'] as String, 
                                                      style: TextStyle(
                                                        decoration: value.overdueTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
                                                        ),
                                                  SizedBox(width: width*0.03,),
                                                  const Icon(Icons.access_time_rounded),
                                                  SizedBox(width: width*0.01,),
                                                  Text("${value.overdueTasks[index]['End_Time'] as String} ${value.overdueTasks[index]['Period_Of_Hour'] as String}",
                                                      style: TextStyle(
                                                        decoration: value.overdueTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
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
              );
              }
              }
            ),
            Text(
                "Pending",
                style: TextStyle(
                  fontSize: height*0.04,
                  fontWeight: FontWeight.w500
                ),
              ),
            SizedBox(height: height*0.008,),
            
       
              StatefulBuilder(builder: (BuildContext context , setState) {
              if (Provider.of<NavigationProvider>(context, listen: false).upcomingTasks.isEmpty){
               return Text("Nothing Here");
              }else{
              log("REBUILD UPCOMING BUILDER");
              return Consumer<NavigationProvider>(
                builder: (context, value, child) {
                  log("${value.upcomingTasks.length}");
                return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: value.upcomingTasks.length,
                itemBuilder: (BuildContext context, int index) {                              
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Provider.of<NavigationProvider>(context, listen: false).callbackPossible) {
                        String endTime = value.upcomingTasks[index]['End_Time'] as String;
                        int hour = int.parse(endTime.substring(0,2));
                        int minute = int.parse(endTime.substring(3,5));
                        endTime = "${hour == 0 ? 12 : hour > 12 ? (hour-12) < 10 ? '0${hour-12}' : hour-12 : hour < 10 ? '0$hour' : hour}:${minute == 0 ? '00' : minute < 10 ? '0$minute' : minute}";
                          Provider.of<NavigationProvider>(context, listen: false).updateTaskDetails(value.upcomingTasks[index]['Task_Name'] as String, value.upcomingTasks[index]['Created'] as String, value.upcomingTasks[index]['End_Date'] as String, "$endTime ${value.upcomingTasks[index]['Period_Of_Hour']}", "No", "No", index, "Upcoming", value.upcomingTasks[index]['id'] as int);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetails()));
                        }
                      },
                      child: Container(
                        height: height*0.1,
                        width: width*0.9,
                        decoration: BoxDecoration(
                          color: value.upcomingTasks[index]["Deleted"] as bool? Colors.green.shade800 : Colors.blueGrey.shade900,
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
                                          child: value.upcomingTasks[index]["Deleted"] as bool
                                              ? Icon(Icons.check_circle_outline_rounded, key: const ValueKey('icon1'))
                                              : Icon(
                                                  Icons.check_box_outline_blank_rounded,
                                                  key: const ValueKey('icon2'),
                                                  
                                                )),
                                          onPressed: () {
                                          Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(false);
                                          value.upcomingTasks[index]["Deleted"] = true;
                                          completeTasks(value.upcomingTasks[index], 1);
                                          log("${_controllerBottomCenter.state}");
                                          _controllerBottomCenter.play();
                                          int noCompletedTasks = Provider.of<NavigationProvider>(context, listen: false).noCompletedTasks;
                                          int noUpcomingTasks = Provider.of<NavigationProvider>(context, listen: false).noUpcomingTasks;
                                          Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(false);
                                          Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(noCompletedTasks+1);
                                          Provider.of<NavigationProvider>(context, listen: false).changenoUpcomingTasks(noUpcomingTasks-1);

                                          Timer(Duration(milliseconds: 250), () {  
                                              value.upcomingTasks.removeAt(index);
                                              if (value.upcomingTasks.isNotEmpty) {
                                                Provider.of<NavigationProvider>(context, listen: false).updateUpcomingTask(value.upcomingTasks[0]['Task_Name'] as String, value.upcomingTasks[0]['Created'] as String, value.upcomingTasks[0]['End_Date'] as String, value.upcomingTasks[0]['End_Time'] as String, value.upcomingTasks[0]['Period_Of_Hour'] as String, false);
                                              }
                                              Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(true);
                                          });
                                          Timer(Duration(milliseconds: 1000), () {
                                            setState(() {
                                              
                                            });
                                          });
                                          
                                          }
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
                                                value.upcomingTasks[index]['Task_Name'] as String,
                                                style: TextStyle(
                                                  fontSize: height*0.025,
                                                  decoration: value.upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none
                                                ),
                                                overflow: TextOverflow.ellipsis,                         
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_month_outlined),
                                                  SizedBox(width: width*0.01,),
                                                  Text(value.upcomingTasks[index]['End_Date'] as String, 
                                                      style: TextStyle(
                                                        decoration: value.upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
                                                        ),
                                                  SizedBox(width: width*0.03,),
                                                  const Icon(Icons.access_time_rounded),
                                                  SizedBox(width: width*0.01,),
                                                  Text("${value.upcomingTasks[index]['End_Time'] as String} ${value.upcomingTasks[index]['Period_Of_Hour'] as String}",
                                                      style: TextStyle(
                                                        decoration: value.upcomingTasks[index]["Deleted"] as bool ? TextDecoration.lineThrough : TextDecoration.none),
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
              );
              }
              }
            )
          ,
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