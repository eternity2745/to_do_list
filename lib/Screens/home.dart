import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:to_do_list/Screens/landingPage.dart';
import 'package:to_do_list/Screens/upcomingTasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      
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
          selectedIndex = clickedIndex;// curve: Curves.linear, duration: Duration(milliseconds: 100));
          setState(() {
            
          });
        }
        ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          LandingPage(),
          UpcomingTasks()
        ],
      )
    );
  }
}