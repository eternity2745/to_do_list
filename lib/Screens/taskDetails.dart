import 'dart:async';

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
    return Scaffold(
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
      );
  }
}