import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  bool persistState = true;

  void changePersistState(bool state) {
    persistState = state;
    notifyListeners();
  }

}