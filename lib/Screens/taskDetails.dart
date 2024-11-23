import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';
import 'package:to_do_list/Providers/navProvider.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> with SingleTickerProviderStateMixin{
  late final _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));

  String createdTime = "";
  String createdDate = "";
  String dueDate = "";
  String dueTime = "";

  @override
  void dispose() {
    _animationController.dispose();
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
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (context.mounted) {
              Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
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
                        onPressed: () {}, 
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}