import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'user_image.dart';

Widget userInfoDialog(BuildContext context, UserModel user, bool hasAccess) {
  final String regDate = DateFormat('MM/dd/yy hh:mm a').format(user.createdAt!.toDate());
  final List pointsHistory = user.pointsHistory != null ? List.from(user.pointsHistory!.reversed) : [];
  return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(80),
                    width: double.infinity,
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.green[100], image: getUserImage(context, user.imageurl, user.avatarString)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          user.name.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          hasAccess ? user.email.toString() : '******@mail.com',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Account Created: $regDate',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Points: ${user.points}')),
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Strength: ${user.strength!.toStringAsFixed(2)}')),
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Quiz Played: ${user.totalQuizPlayed}')),
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Question Answered: ${user.totalQuestionAnswered}')),
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Correct Answer: ${user.totalCorrectAns}')),
                            Chip(
                                backgroundColor: Colors.white,
                                labelPadding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
                                label: Text('Incorrect Answer: ${user.totalIncorrectAns}'))
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(
                            Icons.close,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Divider(),
                    pointsHistory.isEmpty
                        ? const Center(
                            child: Text('No history found!'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pointsHistory.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String rawtitle = pointsHistory[index].substring(0, pointsHistory[index].indexOf(' at '));
                              final String title = rawtitle.replaceAll(RegExp(r'[^\w\s]+|\d+'), '');
                              String reward = rawtitle.replaceAll(RegExp(r'[^0-9\-+]'), '');
                              final String subtitle = pointsHistory[index]
                                  .toString()
                                  .substring(pointsHistory[index].toString().indexOf('at '))
                                  .replaceAll('at ', '')
                                  .trim();
                              final String date = DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(subtitle));
                              return ListTile(
                                  horizontalTitleGap: 0,
                                  leading: const Icon(Icons.history),
                                  title: Text(title),
                                  subtitle: Text(date),
                                  trailing: CircleAvatar(
                                    radius: 30,
                                    child: Text(
                                      reward,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ));
                            },
                          ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ));
}
