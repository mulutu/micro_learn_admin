import 'package:flutter/material.dart';

class MenuControllerBloc extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;


  setSeletedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void controlMenu(GlobalKey<ScaffoldState> scaffoldKey) {
    if (!scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.openDrawer();
    }
  }
}
