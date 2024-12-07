// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:to_do_list/Database/database.dart';
import 'package:to_do_list/Providers/navProvider.dart';
// ignore: must_be_immutable
class LandingPage extends StatefulWidget {
  LandingPage({super.key, required this.isPersistState});

  bool isPersistState;

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<
LandingPage> with AutomaticKeepAliveClientMixin{

  DateTime? dateTime;
  final TextEditingController _taskNameTextController = TextEditingController();

  bool _validateTask= false;
  bool _validateDate = false;
  bool _validateTime = false;

  String taskNameText = '';
  String dateText = 'DD/MM/YY';
  String timeText = 'HH:MM';
  String periodOfHourText = '';

  int noCompletedTasks = 0;
  int noUpcomingTasks = 0;
  int noOverdueTasks = 0;

  String? upcTaskName = '';
  String? upcEndDate = '';
  String? upcEndTime = '';
  String? upcperiodOfHour = '';

  String? comTaskName = '';
  String? comCompletedDate = '';
  String? comCompletedTime = '';
  String? comCompletedperiodOfHour = '';

  String hourOfDay = "AM";
  TimeOfDay? time;
  String datePicked = "DD/MM/YY";

  final db = DatabaseService();

  @override
  bool get wantKeepAlive => widget.isPersistState;

  Future addTask(String taskName, String date, String time, String periodOfHour) async {
    log(time);
    await db.createTask(taskName, date, time, periodOfHour);    
  }
  
  Future updateOverDueTasks() async {
    Provider.of<NavigationProvider>(context, listen: false).updateOverDueTasks(checkUpcoming: true);
    //getStatistics();
    getUpcomingTask();
    getLastCompleted();
    //Provider.of<NavigationProvider>(context, listen: false).getStatistics(); //!INCORRECT STATS FETCHED WHEN GIVEN TIME OF 12:00 AM
  }

  Future updateOverDueTasksinit() async {
    //Provider.of<NavigationProvider>(context, listen: false).updateOverDueTasks();
    //getStatistics();
    getUpcomingTask();
    getLastCompleted();
  }

  Future getUpcomingTask() async {
    List<Map<String, Object?>> result = await db.getUpcomingTask(limit: 1);
    log("RESULT $result");
    if (result.isNotEmpty) {
    upcEndTime = result[0]['End_Time'] as String;
    upcEndTime = upcEndTime!.substring(0, upcEndTime!.length - 3);
    int timeHour24 = int.parse(upcEndTime!.substring(0, upcEndTime!.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime!.length == 5?upcEndTime!.substring(3) : upcEndTime!.substring(2)} $upcperiodOfHour";
    Provider.of<NavigationProvider>(context, listen: false).updateUpcomingTask(result[0]['Task_Name'] as String, result[0]['Created'] as String, result[0]['End_Date'] as String, upcEndTime!, result[0]["Period_Of_Hour"] as String, true);

    //Provider.of<NavigationProvider>(context, listen: false).updateUpcomingTasks(result[0]['id'] as int, result[0]['Task_Name'] as String, result[0]['Created'] as String, result[0]['End_Date'] as String, upcEndTime as String, result[0]['Period_Of_Hour'] as String);
    }
  }

  Future getLastCompleted() async {
    List<Map<String, Object?>> result = await db.getCompletedTasks(limit: 1);
    if(result.isNotEmpty) {
      comTaskName = result[0]['Task_Name'] as String;
      comCompletedDate = result[0]['Completed_Date'] as String;
      comCompletedTime = result[0]['Completed_Time'] as String;
      comCompletedperiodOfHour = result[0]['Completed_Period_Of_Hour'] as String;
      comCompletedTime = comCompletedTime!.substring(0, comCompletedTime!.length - 3);
      int timeHour24 = int.parse(comCompletedTime!.substring(0, comCompletedTime!.length-3));
      comCompletedTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${comCompletedTime!.length == 5?comCompletedTime!.substring(3) : comCompletedTime!.substring(2)} $comCompletedperiodOfHour";
      setState(() {
        
      });
    }
    }

  Future getTask(String id) async {
    log("GEtting task");
    List<Map<String, Object?>> details = await db.getTaskDetails();
    log('$details');
  }

  Future getStatistics() async {
    List statistics = await db.getStatistics();
    Provider.of<NavigationProvider>(context, listen: false).changenoUpcomingTasks(statistics[0]);
    Provider.of<NavigationProvider>(context, listen: false).changenoCompletedTasks(statistics[1]);
    Provider.of<NavigationProvider>(context, listen: false).changenoOverdueTasks(statistics[2]);
    
  }

  Future<void> _selectDate(BuildContext context, setState) async {
    dateTime = await showDatePicker(
                          context: context, 
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000)
                          );
    if (dateTime != null) {
      setState(() {
        dateText = "${dateTime!.day.toString().padLeft(2, '0')}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";
        _validateDate = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, setState) async {
    time = await showTimePicker(
            context: context, 
            initialTime: const TimeOfDay(hour: 00, minute: 00)
          );

    if (time != null) {
      setState(() {  
        timeText = "${time!.hour == 0 ? 12 : time!.hour > 12 ? (time!.hour-12) < 10 ? '0${time!.hour-12}' : time!.hour-12 : time!.hour < 10 ? '0${time!.hour}' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}";
        periodOfHourText = time!.period.name == 'am' ? "AM" : "PM";
        _validateTime = false;
      });
    }
  }

  @override
  void initState() {
    log("OKKK");
    updateOverDueTasksinit();
    super.initState();
  }

  @override
  void dispose() {
    _taskNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (wantKeepAlive) {
     super.build(context);
   }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          "To Do Lists",
          style: TextStyle(
            fontSize: height/25,
            fontWeight: FontWeight.bold
          ),
          )
        ),
      floatingActionButton: Animate(
        onPlay: (controller) {
          controller.repeat(reverse: true);
        },
        onComplete: (controller) {
        },
        effects: [BoxShadowEffect(begin: BoxShadow(color: Colors.deepPurple.shade900, blurRadius: height*0.01), end: BoxShadow(color: Colors.deepPurple.shade300, blurRadius: height*0.013), duration: Duration(milliseconds: 2000), borderRadius: BorderRadius.circular(15))],
        autoPlay: true,
        child: FloatingActionButton.extended(
          enableFeedback: true,
          label: Text("Create Task"),
          icon: Icon(
            Icons.add,
            size: height*0.035,
          ),
            onPressed: () {
              showDialog(context: context, 
              barrierDismissible: false,
              barrierColor: Colors.black87,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder:(context, setState) {             
                return PopScope(
                  canPop: true,
                  onPopInvokedWithResult: (didPop, popped) {
                    if (didPop) {
                      _taskNameTextController.text = "";
                      dateText = "DD/MM/YY";
                      timeText = "HH:MM";
                      periodOfHourText = "";
                      _validateTask = false;
                      _validateTime = false;
                      _validateDate = false;
                    }
                  },
                  child: Dialog(
                    elevation: height*0.1,
                    // ignore: sized_box_for_whitespace
                    child: Container(
                      height: height*0.42,
                      width: width*0.8,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: height*0.02, horizontal: width*0.05),
                        child: Column(
                          children: [
                            Text("Create New Task", 
                            style: TextStyle(
                              fontSize: height*0.03,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                            SizedBox(height: height*0.03,),
                            // ignore: prefer_const_constructors
                            SizedBox(
                              height: height*0.07,
                              child: TextField(
                                // key: _taskNameKey,
                                controller: _taskNameTextController,
                                decoration: InputDecoration( 
                                  labelText: "Task Name",
                                  labelStyle: TextStyle(
                                    color: _validateTask ? Colors.red.shade400 : Colors.white70
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: _validateTask ? Colors.red.shade400 : Colors.white60)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: _validateTask ? Colors.red.shade400 : Colors.white60)),
                                  
                                ),
                                onChanged: (value) {
                                  if (_validateTask == true) {
                                    setState(() {
                                      _validateTask = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: height*0.02,),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, setState);
                              },
                              child: Container(
                                //duration: Durations.extralong4,
                                padding: EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.04),
                                decoration: BoxDecoration(
                                  border: Border.all(color: _validateDate? Colors.red : Colors.white60),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dateText,
                                    style: TextStyle(color: _validateDate ? Colors.red.shade400 : Colors.white70),
                                    ),
                                    Icon(Icons.calendar_month_rounded,
                                    color: _validateDate ? Colors.red.shade400 : Colors.white70,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height*0.02,),
                            GestureDetector(
                              onTap: () {
                                _selectTime(context, setState);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.04),
                                decoration: BoxDecoration(
                                  border: Border.all(color: _validateTime ? Colors.red.shade400 : Colors.white60),
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("$timeText $periodOfHourText",
                                    style: TextStyle(
                                      color: _validateTime ? Colors.red.shade400 : Colors.white70
                                    ),
                                    ),
                                    Icon(Icons.access_time_rounded, 
                                    color : _validateTime ? Colors.red.shade400 : Colors.white70
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height*0.02,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (_taskNameTextController.text != '' && dateText != 'DD/MM/YY' && timeText != 'HH:MM') {
                                    
                                    addTask(_taskNameTextController.text, dateText, "${time!.hour < 10 && time!.hour > 0 ? '0${time!.hour}' : time!.hour == 0 ? '00' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}", periodOfHourText);
                                    Provider.of<NavigationProvider>(context, listen: false).changePersistStateUpcoming(true);
                                    updateOverDueTasks();
                                    setState(() 
                                    {
                                      _taskNameTextController.text = "";
                                      dateText = "DD/MM/YY";
                                      timeText = "HH:MM";
                                      periodOfHourText = "";
                                      _validateTask = false;
                                      _validateTime = false;
                                      _validateDate = false;
                                    });
                                    Navigator.pop(context);
                                    }else{
                                      log("HEHE");
                                      setState(()
                                    {
                                      _validateTask = _taskNameTextController.text == '' ? true : false;
                                      _validateTime = timeText == "HH:MM" ? true : false;
                                      _validateDate = dateText == "DD/MM/YY" ? true : false;
                                    });
                                    }
                                  }, 
                                  child: Text("Done")
                                  ),
                                  TextButton(
                                  onPressed: () {
                                    _taskNameTextController.text = "";
                                    dateText = "DD/MM/YY";
                                    timeText = "HH:MM";
                                    periodOfHourText = "";
                                    _validateTask = false;
                                    _validateTime = false;
                                    _validateDate = false;
                                    Navigator.pop(context);
                                  }, 
                                  child: Text("Cancel")
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                  }
                );
              }
              );
            },
          ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height*0.06, horizontal: width*0.08),
          child: Column(
            children: [
              Container(
                height: height*0.16,
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
                      Text("Upcoming",
                      style: TextStyle(
                        fontSize: height*0.03,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                      SizedBox(height: height*0.02,),
                      if (Provider.of<NavigationProvider>(context).noUpcomingTasks == 0)...{
                        Align(
                        alignment: Alignment.center,
                        child: Text(
                          "   There Are No\nUpcoming Tasks",
                          style: TextStyle(
                            fontSize: height*0.025,
                            fontWeight: FontWeight.w500
                          ),
                        //overflow: TextOverflow.ellipsis,
                        )
                        )
                      }else...{                     
                      Expanded(
                        child: Consumer<NavigationProvider>(
                          builder: (context, value, child) {                            
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SizedBox(width: width*0.05),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: height*0.008, bottom: height*0.01),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                          value.upcomingTask,
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
                                            Text(value.upcomingEndDate),
                                            SizedBox(width: width*0.03,),
                                            const Icon(Icons.access_time_rounded),
                                            SizedBox(width: width*0.01,),
                                            Text("${value.upcomingEndTime} ${value.upcomingPeriodOfHour}")
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          
                          );
                          }
                        ),
                      )
                      }
                    ],
                  ),
                ),
              ),
            SizedBox(height: height*0.05,),
            Container(
                height: height*0.16,
                width: width*0.9,
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: height*0.008, horizontal: width*0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last Completed",
                      style: TextStyle(
                        fontSize: height*0.03,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                      SizedBox(height: height*0.02,),
                      if (Provider.of<NavigationProvider>(context).noCompletedTasks == 0)...{
                        Align(
                        alignment: Alignment.center,
                        child: Text(
                          "   There Are No\nCompleted Tasks",
                          style: TextStyle(
                            fontSize: height*0.025,
                            fontWeight: FontWeight.w500
                          ),
                        //overflow: TextOverflow.ellipsis,
                        )
                        )
                      }else...{
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              SizedBox(width: width*0.05),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: height*0.008, bottom: height*0.01),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(comTaskName!,
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
                                          Text(comCompletedDate!),
                                          SizedBox(width: width*0.03,),
                                          const Icon(Icons.access_time_rounded),
                                          SizedBox(width: width*0.01,),
                                          Text(comCompletedTime!)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                      }
                    ],
                  ),
                ),
              ),
            SizedBox(height: height*0.04,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height*0.224,
                  width: width*0.47,
                  decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(14),
                ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: height*0.01, horizontal: width*0.01),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Overdue", 
                        style: TextStyle(
                          fontSize: height*0.03,
                          fontWeight: FontWeight.w500
                        ),
                        ),
                        SizedBox(height: height*0.018,),
                        Consumer<NavigationProvider>(
                          builder: (context, value, child) {
                            return Text("${value.noOverdueTasks}",
                            style: TextStyle(
                            fontSize: height*0.07,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade500
                          ),
                          );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              SizedBox(width: width*0.015,),
              Column(
                children: [
                  Container(
                      height: height*0.11,
                      width: width*0.33,
                      decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(14),
                    ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: height*0.01, horizontal: width*0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Pending", 
                            style: TextStyle(
                              fontSize: height*0.02,
                              fontWeight: FontWeight.w500
                            ),
                            ),
                            SizedBox(height: height*0.001,),
                            Consumer<NavigationProvider>(
                              builder: (context, value, child) {
                                return Text("${value.noUpcomingTasks}",
                                style: TextStyle(
                                fontSize: height*0.04,
                                fontWeight: FontWeight.bold
                              ),
                              );
                              },
                              
                            )
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: height*0.003,),
                  Container(
                      height: height*0.11,
                      width: width*0.33,
                      decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(14),
                    ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: height*0.01, horizontal: width*0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Completed", 
                            style: TextStyle(
                              fontSize: height*0.02,
                              fontWeight: FontWeight.w500
                            ),
                            ),
                            SizedBox(height: height*0.001,),
                            Consumer<NavigationProvider>(
                              builder: (context, value, child) {
                                return Text("${value.noCompletedTasks}",
                                style: TextStyle(
                                fontSize: height*0.04,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade500
                              ),
                              );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              )
              ],
            ) 
            ],         
          ),
        ),
      ),
    );
}
}