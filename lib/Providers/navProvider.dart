import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  bool persistStateUpcoming = true;
  bool persistStateLanding = true;
  bool persistStateCompleted = true;

  int noOverdueTasks = 0;
  int noCompletedTasks = 0;
  int noUpcomingTasks = 0;

  void changenoOverdueTasks(int number) {
    noOverdueTasks = number;
    notifyListeners();
  }

  void changenoCompletedTasks(int number) {
    noCompletedTasks = number;
    notifyListeners();
  }

  void changenoUpcomingTasks(int number) {
    noUpcomingTasks = number;
    notifyListeners();
  }

  void changePersistStateUpcoming(bool state) {
    persistStateUpcoming = state;
    notifyListeners();
  }

  void changePersistStateLanding(bool state) {
    persistStateLanding = state;
    notifyListeners();
  }

  void changePersistStateCompleted(bool state) {
    persistStateCompleted = state;
    notifyListeners();
  }
}