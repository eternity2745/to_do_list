// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
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
  final TextEditingController _dateTimeTextController = TextEditingController();
  final TextEditingController _timeTextController = TextEditingController();
  final DropdownController _dropdownController = DropdownController(); 
  final TextEditingController _taskNameTextController = TextEditingController();

  bool _validateTask= false;
  bool _validateDateTime= false;
  bool _validateTime = false;


  String taskNameText = '';
  String dateText = '';
  String timeText = '';

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

  Future<void> _selectDate(BuildContext context) async {
    dateTime = await showDatePicker(
                          context: context, 
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000)
                          );
    if (dateTime != null) {
      setState(() {
        _dateTimeTextController.text = "${dateTime!.day.toString().padLeft(2, '0')}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";//${dateTime!.hour.toString().padLeft(2,'0')}-${dateTime!.minute.toString().padLeft(2,'0')}
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    time = await showTimePicker(
            context: context, 
            initialTime: const TimeOfDay(hour: 00, minute: 00)
          );

    if (time != null) {
      setState(() {  
        _timeTextController.text = "${time!.hour == 0 ? 12 : time!.hour > 12 ? (time!.hour-12) < 10 ? '0${time!.hour-12}' : time!.hour-12 : time!.hour < 10 ? '0${time!.hour}' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}";
        hourOfDay = time!.period.name == 'am' ? "AM" : "PM";
        _dropdownController.setValue(CoolDropdownItem(label: hourOfDay, value: hourOfDay));
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
    _dateTimeTextController.dispose();
    _dropdownController.dispose();
    _timeTextController.dispose();
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
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        iconSize: height*0.05,
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.green),
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
                  _timeTextController.text = "";
                  _dateTimeTextController.text = "";
                  _taskNameTextController.text = "";
                }
              },
              child: Dialog(
                elevation: height*0.1,
                // ignore: sized_box_for_whitespace
                child: Container(
                  height: height*0.44,
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              errorText : _validateTask ? '' : null,
                            ),
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return 'Empty';
                              //   }else{
                              //     return null;
                              //   }
                              // },
                          ),
                        ),
                        SizedBox(height: height*0.02,),
                        SizedBox(
                          height: height*0.07,
                          child: TextField(
                            //key: _dateTimeKey,
                            controller: _dateTimeTextController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_month_outlined),
                                onPressed: () {
                                  _selectDate(context);
                                }
                              ),
                              labelText: "DD/MM/YY",
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              errorText : _validateDateTime ? '' : null,
                              // errorStyle: _validateDateTime? TextStyle(
                              //   color: Colors.red
                              // ) : null
                            ),
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return 'Empty';
                            //   }else{
                            //     return null;
                            //   }
                            // },
                          ),
                        ),
                        SizedBox(height: height*0.02,),
                        Row(
                          children: [
                            SizedBox(
                              width: width*0.48,
                              height: height*0.07,
                              child: TextField(
                                // key: _timeKey,
                                controller: _timeTextController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.access_time_rounded),
                                    onPressed: () {
                                      _selectTime(context);
                                    },
                                  ),
                                  labelText: "HH:MM",
                                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                  errorText : _validateTime ? '' : null,
                                  //errorStyle: TextStyle(height: 0)
                                ),
                            //       validator: (value) {
                            //         if (value!.isEmpty) {
                            //           return 'Empty';
                            //         }else{
                            //           return null;
                            //         }
                            // },
                              ),
                            ),
                            SizedBox(width: width*0.02,),
                            SizedBox(
                              width: width*0.2,
                              height: height*0.05,
                              child: CoolDropdown(
                                defaultItem : CoolDropdownItem(label: hourOfDay, value: hourOfDay),
                                resultOptions: ResultOptions(
                                  //placeholder: hourOfDay,
                                  placeholderTextStyle: TextStyle(
                                    color: Colors.grey.shade300
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade300
                                  ),
                                  boxDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border(top: BorderSide(color: Colors.grey), bottom: BorderSide(color: Colors.grey), left: BorderSide(color: Colors.grey), right: BorderSide(color: Colors.grey)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  openBoxDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border(top: BorderSide(color: Colors.grey), bottom: BorderSide(color: Colors.grey), left: BorderSide(color: Colors.grey), right: BorderSide(color: Colors.grey)),
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                ),
                                dropdownList: [
                                  CoolDropdownItem(
                                    label: "AM", 
                                    value: "AM"
                                    ),
                                    CoolDropdownItem(
                                      label: "PM", 
                                      value: "PM"
                                      )
                                ], 
                                dropdownOptions: DropdownOptions(
                                  color: Colors.grey.shade900,
                                  animationType: DropdownAnimationType.scale,
                                  curve: Curves.linear
                                ),
                                dropdownItemOptions: DropdownItemOptions(
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade300
                                  )
                                ),
                                controller: _dropdownController, 
                                onChange: (change) {
              
                                }
                                ),
                              // child: const TextField(
                              //   decoration: const InputDecoration(
                              //     border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                              //   ),                             
                              // ),
                            ),
                          ],
                        ),
                        SizedBox(height: height*0.02,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          
                          children: [
                            TextButton(
                              onPressed: () {
                                if (_taskNameTextController.text != '' && _dateTimeTextController.text != '' && _timeTextController.text != '') {
                                
                                addTask(_taskNameTextController.text, _dateTimeTextController.text, "${time!.hour < 10 && time!.hour > 0 ? '0${time!.hour}' : time!.hour == 0 ? '00' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}", hourOfDay);
                                Provider.of<NavigationProvider>(context, listen: false).changePersistStateUpcoming(true);
                                updateOverDueTasks();
                                setState(() 
                                {
                                  _taskNameTextController.text = "";
                                  _dateTimeTextController.text = "";
                                  _timeTextController.text = "";
                                });
                                Navigator.pop(context);
                                }else{
                                  log("HEHE");
                                  setState(() 
                                {
                                  _validateTask = true;
                                  _validateDateTime = true;
                                  _validateTime = true;
                                });
                                }
                              }, 
                              child: Text("Done")
                              ),
                              TextButton(
                              onPressed: () {
                                _taskNameTextController.text = "";
                                _dateTimeTextController.text = "";
                                _timeTextController.text = "";
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