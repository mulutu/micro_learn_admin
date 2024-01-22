import 'package:app_admin/configs/config.dart';
import 'package:flutter/material.dart';

class CardWrapper extends StatelessWidget {
  const CardWrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Config.defaultPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Config.defaultPadding),
          child: child,
        ),
      ),
    );
  }
}