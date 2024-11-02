import 'dart:developer';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:to_do_list/Database/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  DateTime? dateTime;
  final TextEditingController _dateTimeTextController = TextEditingController();
  final TextEditingController _timeTextController = TextEditingController();
  final DropdownController _dropdownController = DropdownController(); 
  final TextEditingController _taskNameTextController = TextEditingController();

  String taskNameText = '';
  String dateText = '';
  String timeText = '';

  String? upcTaskName = '';
  String? upcEndDate = '';
  String? upcEndTime = '';
  String? upcperiodOfHour = '';

  String hourOfDay = "AM";
  TimeOfDay? time;
  String datePicked = "DD/MM/YY";

  

  final db = DatabaseService();

  Future<void> addTask(String taskName, String date, String time, String periodOfHour) async {
    log(time);
    db.createTask(taskName, date, time, periodOfHour);
    getTask("3443");
  }

  Future getUpcomingTask() async {
    List<Map<String, Object?>> result = await db.getUpcomingTask();
    log("$result");
    upcTaskName = result[0]['Task_Name'] as String;
    upcEndDate = result[0]['End_Date'] as String;
    upcEndTime = result[0]['End_Time'] as String;
    upcperiodOfHour = result[0]['Period_Of_Hour'] as String;
    upcEndTime = upcEndTime!.substring(0, upcEndTime!.length - 3);
    int timeHour24 = int.parse(upcEndTime!.substring(0, upcEndTime!.length-3));
    upcEndTime = "${timeHour24 == 0 ? 12 : timeHour24 > 12 ? (timeHour24-12) < 10 ? '0${timeHour24-12}' : timeHour24-12 : timeHour24 < 10 ? '0$timeHour24' : timeHour24}:${upcEndTime!.length == 5?upcEndTime!.substring(3) : upcEndTime!.substring(2)} $upcperiodOfHour";
    setState(() {
      
    });
  }

  Future getTask(String id) async {
    log("GEtting task");
    List<Map<String, Object?>> details = await db.getTaskDetails();
    log('${details.length}');
    log('${details}');
    log('${details.last}');
  }

  Future<void> _selectDate(BuildContext context) async {
    dateTime = await showDatePicker(
                          context: context, 
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000)
                          );
    if (dateTime != null) {
      setState(() {
        _dateTimeTextController.text = "${dateTime!.day.toString()}/${dateTime!.month.toString().padLeft(2,'0')}/${dateTime!.year.toString().padLeft(2,'0')}";//${dateTime!.hour.toString().padLeft(2,'0')}-${dateTime!.minute.toString().padLeft(2,'0')}
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
    getUpcomingTask();
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
            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, popped) {
                if (didPop) {
                  _timeTextController.text = "";
                  _dateTimeTextController.text = "";
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
                        TextField(
                          controller: _taskNameTextController,
                          decoration: const InputDecoration( 
                            labelText: "Task Name",
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                          ),
                        ),
                        SizedBox(height: height*0.02,),
                        TextField(
                          controller: _dateTimeTextController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_month_outlined),
                              onPressed: () {
                                _selectDate(context);
                              }
                            ),
                            labelText: "DD/MM/YY",
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                          ),
                        ),
                        SizedBox(height: height*0.02,),
                        Row(
                          children: [
                            SizedBox(
                              width: width*0.48,
                              child: TextField(
                                controller: _timeTextController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.access_time_rounded),
                                    onPressed: () {
                                      _selectTime(context);
                                    },
                                  ),
                                  labelText: "HH:MM",
                                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))
                                ),                             
                              ),
                            ),
                            SizedBox(width: width*0.02,),
                            SizedBox(
                              width: width*0.2,
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
                                addTask(_taskNameTextController.text, _dateTimeTextController.text, "${time!.hour < 10 && time!.hour > 0 ? '0${time!.hour}' : time!.hour}:${time!.minute == 0 ? '00' : time!.minute < 10 ? '0${time!.minute}' : time!.minute}", hourOfDay);
                                _dateTimeTextController.text = "";
                                _timeTextController.text = "";
                                Navigator.pop(context);
                              }, 
                              child: Text("Done")
                              ),
                              TextButton(
                              onPressed: () {
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
        },
      ),
      bottomNavigationBar: MoltenBottomNavigationBar(
        tabs: [
          MoltenTab(icon: Icon(Icons.home_outlined, size: height*0.035,)),
          MoltenTab(icon: Icon(Icons.timelapse_outlined, size: height*0.035)),
          MoltenTab(icon: Icon(Icons.person_outline, size: height*0.035))
        ]
        , 
        selectedIndex: selectedIndex,
        barColor: Colors.green.shade900, 
        barHeight: height*0.08,
        onTabChange: (clickedIndex) {
          selectedIndex = clickedIndex;
          setState(() {
            
          });
        }
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
                                        upcTaskName!,
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
                                          Text(upcEndDate!),
                                          SizedBox(width: width*0.03,),
                                          const Icon(Icons.access_time_rounded),
                                          SizedBox(width: width*0.01,),
                                          Text(upcEndTime!)
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
            SizedBox(height: height*0.05,),
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
                      Text("Last Completed",
                      style: TextStyle(
                        fontSize: height*0.03,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                      SizedBox(height: height*0.02,),
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
                                        child: Text("Maths HW afwefeawf wawfawaf",
                                        style: TextStyle(
                                          fontSize: height*0.025
                                        ),
                                        overflow: TextOverflow.ellipsis,                         
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_month_outlined),
                                          const Text("Sun, 23rd May"),
                                          SizedBox(width: width*0.03,),
                                          const Icon(Icons.access_time_rounded),
                                          const Text("12:00 pm")
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
            SizedBox(height: height*0.05,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height*0.17,
                  width: width*0.5,
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
                          fontSize: height*0.03,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                        SizedBox(height: height*0.018,),
                        Text("100",
                        style: TextStyle(
                          fontSize: height*0.05,
                          fontWeight: FontWeight.bold
                        ),
                        )
                      ],
                    ),
                  ),
                ),
              SizedBox(width: width*0.01,),
              Container(
                  height: height*0.17,
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
                          fontSize: height*0.03,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                        SizedBox(height: height*0.018,),
                        Text("100",
                        style: TextStyle(
                          fontSize: height*0.05,
                          fontWeight: FontWeight.bold
                        ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ) 
            ],         
          ),
        ),
      ),
    );
    log("ENDED");
  }
}