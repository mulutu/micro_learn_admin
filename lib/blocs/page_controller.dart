import 'package:flutter/material.dart';

class PageViewController extends ChangeNotifier {
  int _oldPageIndex = 0;
  int get oldPageIndex => _oldPageIndex;

  void controllPage(PageController pageController, int pageNumber) {
    bool animate = _shouldAnimate(pageNumber);
    if (animate) {
      pageController.animateToPage(
        pageNumber,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      pageController.jumpToPage(pageNumber);
    }
    notifyListeners();
    _updateOldPageIndex(pageNumber);
  }

  bool _shouldAnimate(int newIndex) {
    int dif = _oldPageIndex - newIndex;
    if (dif > 1 || dif < -1) {
      return false;
    } else {
      return true;
    }
  }

  _updateOldPageIndex(newIndex) {
    _oldPageIndex = newIndex;
    notifyListeners();
  }
}
