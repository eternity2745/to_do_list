import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/navProvider.dart';
import 'package:to_do_list/Screens/completedTasks.dart';
import 'package:to_do_list/Screens/landingPage.dart';
import 'package:to_do_list/Screens/upcomingTasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    Provider.of<NavigationProvider>(context, listen: false).updateOverDueTasks();
    Provider.of<NavigationProvider>(context, listen: false).getCompletedTasks();
    Provider.of<NavigationProvider>(context, listen: false).getUpcomingTasks();
    Provider.of<NavigationProvider>(context, listen: false).getOverdueTasks();
    Provider.of<NavigationProvider>(context, listen: false).getStatistics();
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        items: [
          Icon(Icons.home_outlined, size: height*0.035,),
          Icon(Icons.timelapse_outlined, size: height*0.035),
          Icon(Icons.done_outline_rounded, size: height*0.035)
        ]
        ,
        index: selectedIndex,
        buttonBackgroundColor: Colors.deepPurple.shade600,
        color: Colors.blue.shade900,
        height: height*0.08,
        backgroundColor: Colors.transparent,
        animationDuration: Duration(milliseconds: 400),
        onTap: (clickedIndex) {
          selectedIndex = clickedIndex;
          Provider.of<NavigationProvider>(context, listen: false).updateOverDueTasks();
          if ((selectedIndex == 0 || selectedIndex == 2) && Provider.of<NavigationProvider>(context, listen: false).persistStateUpcoming == false) {            
            Provider.of<NavigationProvider>(context, listen: false).changePersistStateUpcoming(true);
          }else if((selectedIndex == 1 || selectedIndex == 2) && Provider.of<NavigationProvider>(context, listen: false).persistStateLanding == false) {
            Provider.of<NavigationProvider>(context, listen: false).changePersistStateLanding(true);
          }else if((selectedIndex == 0 || selectedIndex == 1) && Provider.of<NavigationProvider>(context, listen: false).persistStateCompleted == false){
            Provider.of<NavigationProvider>(context, listen: false).changePersistStateCompleted(true);
          }
          _pageController.jumpToPage(selectedIndex);// curve: Curves.linear, duration: Duration(milliseconds: 100));
          setState(() {
            
          });
        }
        ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          LandingPage(isPersistState: true,),
          UpcomingTasks(isPersistState: true,),
          CompletedTasks()
        ],
      )
    );
  }
}