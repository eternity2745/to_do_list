import 'dart:async';
import 'dart:developer';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';
import 'package:to_do_list/Database/database.dart';
import 'package:to_do_list/Providers/navProvider.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> with SingleTickerProviderStateMixin{
  late final _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
  final ConfettiController _controllerBottomCenter = ConfettiController(duration: Duration(milliseconds: 350));

  String createdTime = "";
  String createdDate = "";
  String dueDate = "";
  String dueTime = "";
  int index = 0;

  DateTime? dateTime;
  TimeOfDay? time;

  final db = DatabaseService();

  Future completeTasks(Map<String, Object?> details, int tableNumber) async {
    DateTime dateTime = DateTime.now();
    String periodOfHour = dateTime.hour < 12 ? "AM" : "PM";
    String time = "${dateTime.hour < 10 && dateTime.hour > 0 ? '0${dateTime.hour}' : dateTime.hour == 0 ? '00' : dateTime.hour}:${dateTime.minute == 0 ? '00' : dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute}:00";
    String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    details['Completed_Time'] = time;
    details['Completed_Date'] = date;
    details['Completed_Period_Of_Hour'] = periodOfHour;

    Map<String, Object?> detailsReplica = { for (var e in details.keys) e : details[e] };
    Provider.of<NavigationProvider>(context, listen: false).updateCompletedTasks(details['id'] as int, details['Task_Name'] as String, details['Completed_Date'] as String, details['Completed_Time'] as String, details['Completed_Period_Of_Hour'] as String, details['Created'] as String, details['End_Date'] as String, details['End_Time'] as String, details['Period_Of_Hour'] as String);
    await db.completeTask(detailsReplica, tableNumber);
  }

  Future<void> _selectDate(BuildContext context, int selectedIndex, int id, String selectedTaskType) async {
    dateTime = await showDatePicker(
                          context: context, 
                          initialDate: selectedTaskType == "Upcoming" ? DateTime.now().add(Duration(days: 1)) : DateTime.now(),
                          firstDate: selectedTaskType == "Upcoming" ? DateTime.now().add(Duration(days: 1)) : DateTime.now(),
                          lastDate: DateTime(3000),
                          );
    if (dateTime != null) {
      if (context.mounted) {
        if (selectedTaskType == "Upcoming") {
          Provider.of<NavigationProvider>(context, listen: false).upcomingTasks[selectedIndex]["End_Date"] = "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";
          Map<String, Object?> upcomingEditTask = Provider.of<NavigationProvider>(context, listen: false).upcomingTasks[selectedIndex];
          Provider.of<NavigationProvider>(context, listen: false).upcomingTasks.removeAt(selectedIndex);
          Provider.of<NavigationProvider>(context, listen: false).editTaskDetails(dueDate: "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}", notify: false);
          Provider.of<NavigationProvider>(context, listen: false).updateUpcomingTasks(task: upcomingEditTask);
          await db.editTask(id, 1, dueDate: "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}");
        }else{
          Provider.of<NavigationProvider>(context, listen: false).overdueTasks[selectedIndex]["End_Date"] = "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";
          Map<String, Object?> ovrdEditTask = Provider.of<NavigationProvider>(context, listen: false).overdueTasks[selectedIndex];
          Provider.of<NavigationProvider>(context, listen: false).editTaskDetails(dueDate: "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}", notify: false);
          Provider.of<NavigationProvider>(context, listen: false).updateEditOverdueTasks(selectedIndex, ovrdEditTask);
          
        }
        
      }
    }
  }

  Future<void> _selectTime(BuildContext context, int selectedIndex, int id, String selectedTaskType, String dueDate) async {
    time = await showTimePicker(
            context: context, 
            initialTime: TimeOfDay.now()
          );
    DateTime today = DateTime.now();
    String todayDate = "${today.day}/${today.month}/${today.year}";
    if (time != null && context.mounted) {
      if (time!.hour <= TimeOfDay.now().hour && todayDate == dueDate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Row( 
            children: [ 
            Icon(Icons.warning),
            SizedBox(width: MediaQuery.of(context).size.width*0.02,),
            Text(
            time!.hour < TimeOfDay.now().hour ? "Selected Time Cant Be Past Current Time" : "Selected Time Cant Be Current Time",
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
            ),
            )
            ]
          ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.02, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
            backgroundColor: Colors.red,
            dismissDirection: DismissDirection.none,
          ),
          snackBarAnimationStyle: AnimationStyle(
            curve: Curves.easeInToLinear
          )
        );
      }else{
        if (selectedTaskType == "Upcoming") {
          String dueTimeOG = "${time!.hour == 0 ? 12 : time!.hour > 12 ? (time!.hour-12) < 10 ? '0${time!.hour-12}' : time!.hour-12 : time!.hour < 10 ? '0${time!.hour}' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}";
          String duePeriod = time!.period.name.toUpperCase();
          String hr24 = "${time!.hour < 10 ? '0${time!.hour}' : time!.hour}:${time!.minute<10 ? '0${time!.minute}' : time!.minute}:00";
          Provider.of<NavigationProvider>(context, listen: false).upcomingTasks[selectedIndex]["End_Time"] = dueTimeOG;
          Provider.of<NavigationProvider>(context, listen: false).upcomingTasks[selectedIndex]["Period_Of_Hour"] = duePeriod;
          Map<String, Object?> upcomingEditTask = Provider.of<NavigationProvider>(context, listen: false).upcomingTasks[selectedIndex];
          Provider.of<NavigationProvider>(context, listen: false).upcomingTasks.removeAt(selectedIndex);
          Provider.of<NavigationProvider>(context, listen: false).editTaskDetails(dueTime: "$dueTimeOG $duePeriod", notify: false);
          Provider.of<NavigationProvider>(context, listen: false).updateUpcomingTasks(task: upcomingEditTask);
          log(hr24);
          log(duePeriod);
          await db.editTask(id, 1, dueTime: "${time!.hour < 10 ? '0${time!.hour}' : time!.hour}:${time!.minute<10 ? '0${time!.minute}' : time!.minute}", duePeriod: duePeriod);
        }else{
          Provider.of<NavigationProvider>(context, listen: false).overdueTasks[selectedIndex]["End_Date"] = "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";
          Map<String, Object?> ovrdEditTask = Provider.of<NavigationProvider>(context, listen: false).overdueTasks[selectedIndex];
          Provider.of<NavigationProvider>(context, listen: false).editTaskDetails(dueDate: "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}", notify: false);
          Provider.of<NavigationProvider>(context, listen: false).updateEditOverdueTasks(selectedIndex, ovrdEditTask);
          
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(
          "Task Details",
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
                  Container(
                    height: height*0.2,
                    width: width*0.9,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      //gradient: LinearGradient(colors: [Colors.green.shade900, Colors.blue.shade900]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: height*0.008,),
                      child: Snappable(
                        animation: _animationController,
                        child: SizedBox(
                          height: height*0.135,
                          child: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return AutoSizeText(
                                value.taskName,
                                style: TextStyle(
                                  fontSize: height*0.1,
                                  fontWeight: FontWeight.w600
                                ),
                                );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Snappable(
                    animation: _animationController,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          leading: Text(
                            "Created Date",
                            style: TextStyle(
                              fontSize: height*0.03,
                            ),
                          ),
                          trailing: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return TextButton(
                              child: Text(
                              value.createdDate,
                              style: TextStyle(
                                fontSize: height*0.02
                              ),
                              ),
                            onPressed: () {
                              
                            },
                            );
                            },
                          ),
                        ),
                        Divider(endIndent: width*0.03,),
                        // ListTile(
                        //   leading: Text(
                        //     "Created Time",
                        //     style: TextStyle(
                        //       fontSize: height*0.03,
                        //     ),
                        //   ),
                        //   trailing: TextButton(
                        //     child: Text(
                        //   createdTime,
                        //   style: TextStyle(
                        //     fontSize: height*0.02
                        //   ),
                        //   ),
                        //   onPressed: () {
                            
                        //   },
                        //   ),
                        // ),
                        // Divider(endIndent: width*0.03,),
                        ListTile(
                          leading: Text(
                            "Due Date",
                            style: TextStyle(
                              fontSize: height*0.03,
                            ),
                          ),
                          trailing: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return TextButton(
                              child: Text(
                              value.dueDate,
                              style: TextStyle(
                                fontSize: height*0.02
                              ),
                              ),
                            onPressed: () {
                              _selectDate(context, value.selectedIndex, value.upcomingTasks[index]['id'] as int, value.selectedTaskType);
                            },
                            );
                            },
                          ),
                        ),
                        Divider(endIndent: width*0.03,),
                        ListTile(
                          leading: Text(
                            "Due Time",
                            style: TextStyle(
                              fontSize: height*0.03,
                            ),
                          ),
                          trailing: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return TextButton(
                              child: Text(
                              value.dueTime,
                              style: TextStyle(
                                fontSize: height*0.02
                              ),
                              ),
                            onPressed: () {
                              _selectTime(context, value.selectedIndex, value.selectedTaskID, value.selectedTaskType, value.dueDate);
                            },
                            );
                            },
                          ),
                        ),
                        Divider(endIndent: width*0.03,),
                      ListTile(
                          leading: Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: height*0.03,
                            ),
                          ),
                          trailing: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return TextButton(
                              child: Text(
                              value.completed,
                              style: TextStyle(
                                fontSize: height*0.02
                              ),
                              ),
                            onPressed: () {
                              
                            },
                            );
                            },
                          ),
                        ),
                        Divider(endIndent: width*0.03,),
                      ListTile(
                          leading: Text(
                            "Overdue",
                            style: TextStyle(
                              fontSize: height*0.03,
                            ),
                          ),
                          trailing: Consumer<NavigationProvider>(
                            builder: (context, value, child) {
                              return TextButton(
                              child: Text(
                              value.overdue,
                              style: TextStyle(
                                fontSize: height*0.02
                              ),
                              ),
                            onPressed: () {
                              
                            },
                            );
                            },
                          ),
                        ),
                        Divider(endIndent: width*0.03,),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Snappable(
                        animation: _animationController,
                        child: ElevatedButton(
                          onPressed: () {
                            _controllerBottomCenter.play();
                            Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(false);
                            if (Provider.of<NavigationProvider>(context, listen: false).selectedTaskType == "Upcoming") {
                              List<Map<String, Object?>> upcomingTasks = Provider.of<NavigationProvider>(context, listen: false).upcomingTasks;
                              int selectedIndex = Provider.of<NavigationProvider>(context, listen: false).selectedIndex;
                              completeTasks(upcomingTasks[selectedIndex], 1);
                              Provider.of<NavigationProvider>(context, listen:false).upcomingTasks.removeAt(selectedIndex);
                              Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(Provider.of<NavigationProvider>(context, listen: false).completedTasks.length);
                              Provider.of<NavigationProvider>(context, listen: false).changenoUpcomingTasks(Provider.of<NavigationProvider>(context, listen: false).upcomingTasks.length);
                            }else{
                              List<Map<String, Object?>> overdueTasks = Provider.of<NavigationProvider>(context, listen: false).overdueTasks;
                              int selectedIndex = Provider.of<NavigationProvider>(context, listen: false).selectedIndex;
                              completeTasks(overdueTasks[selectedIndex], 1);
                              Provider.of<NavigationProvider>(context, listen:false).overdueTasks.removeAt(selectedIndex);
                              Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(Provider.of<NavigationProvider>(context, listen: false).completedTasks.length);
                              Provider.of<NavigationProvider>(context, listen: false).changenoOverdueTasks(Provider.of<NavigationProvider>(context, listen: false).overdueTasks.length);
                            }
      
                            Timer(
                              Duration(milliseconds: 1000),
                              () {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                Provider.of<NavigationProvider>(context, listen: false).changeCallbackPossible(true);
                              }
                            );
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: Size(width*0.1, height*0.07),
                            enableFeedback: true,
                            elevation: height*0.01
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: height*0.05,
                            )
                          ),
                      ),
                        Snappable(
                          animation: _animationController,
                          child: ElevatedButton(
                          onPressed: () {
                            if (Provider.of<NavigationProvider>(context, listen: false).callbackPossible == false) {
                              return;
                            }
                            if (Provider.of<NavigationProvider>(context, listen: false).selectedTaskType == "Upcoming") {
                              _animationController.forward(from: 0);
                              Provider.of<NavigationProvider>(context, listen: false).deleteUpcTask();
                              Future.delayed(Duration(milliseconds: 2200), () {
                                if (context.mounted) {
                                return Navigator.pop(context);
                                }
                              });
                            }else if(Provider.of<NavigationProvider>(context, listen: false).selectedTaskType == "Overdue") {
                              _animationController.forward(from: 0);
                              Provider.of<NavigationProvider>(context, listen: false).deleteOvrdTask();
                              Future.delayed(Duration(milliseconds: 2200), () {
                                if (context.mounted) {
                                return Navigator.pop(context);
                                }
                              });
                            }else{
                              _animationController.forward(from: 0);
                              Provider.of<NavigationProvider>(context, listen: false).deleteCompTask();
                              Future.delayed(Duration(milliseconds: 2200), () {
                                if (context.mounted) {
                                return Navigator.pop(context);
                                }
                              });
                            }
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: Size(width*0.1, height*0.07),
                            enableFeedback: true,
                            elevation: height*0.011
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: height*0.05,
                            )
                          ),
                        ),
                  ],
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: ConfettiWidget(
                        confettiController: _controllerBottomCenter,
                        blastDirectionality: BlastDirectionality.explosive,
                        emissionFrequency: 0.01,
                        numberOfParticles: 200,
                        maxBlastForce: 100,
                        minBlastForce: 80,
                        gravity: 1,
                    )
                  )
                ],
              ),
            ),
            
          )
        ),
    );
  }
}