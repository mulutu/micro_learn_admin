import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextScreen {
  static void nextScreenNormal(context, page) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => page));
  }

  void nextScreeniOS(context, page) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  void nextScreenCloseOthers(context, page) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(
          builder: (context) => page), (route) => false);
  }

  void nextScreenReplace(context, page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => page));
  }

  void nextScreenPopup(context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (context) => page),
    );
  }

  void nextScreenReplaceAnimation(context, page) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) => page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
    ));
  }

  void nextScreenCloseOthersAnimation(context, page) {
    Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) => page,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
    ), ((route) => false));
  }
}