import 'package:flutter/material.dart';

class TopTitle extends StatelessWidget {
  const TopTitle({Key? key, required this.title, this.dividerWidth}) : super(key: key);

  final String title;
  final double? dividerWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[900]),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            height: 3,
            width: dividerWidth ?? 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
