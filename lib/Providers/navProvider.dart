import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  bool persistStateUpcoming = true;

  void changePersistStateUpcoming(bool state) {
    persistStateUpcoming = state;
    notifyListeners();
  }

}