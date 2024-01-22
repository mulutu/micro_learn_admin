import 'package:app_admin/components/dashboard_card.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_icons/line_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future _users;
  late Future _questions;
  late Future _categories;
  late Future _quizes;
  late Future _notifications;
  late Future _featuredCategories;

  @override
  void initState() {
    _users = FirebaseService().getTotalDocuments('users_count');
    _questions = FirebaseService().getTotalDocuments('questions_count');
    _categories = FirebaseService().getTotalDocuments('cats_count');
    _quizes = FirebaseService().getTotalDocuments('quizes_count');
    _notifications = FirebaseService().getTotalDocuments('notifications_count');
    _featuredCategories = FirebaseService().getTotalDocuments('featured_category_count');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 20),
              child: TopTitle(title: 'Dashboard'),
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppService.getCrossAxisCount(context), childAspectRatio: AppService.getChildAspectRatio(context)),
              children: [
                FutureBuilder(
                  future: _users,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) {
                      return const DashboardCard(
                        info: 'Total Users',
                        count: 0,
                        icon: LineIcons.userCheck,
                      );
                    }
                    if (snap.hasError) {
                      return const DashboardCard(
                        info: 'Total Users',
                        count: 0,
                        icon: LineIcons.userCheck,
                      );
                    }
                    return DashboardCard(
                      info: 'Total Users',
                      count: snap.data,
                      icon: LineIcons.userCheck,
                    );
                  },
                ),
                FutureBuilder(
                  future: _questions,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) {
                      return const DashboardCard(
                        info: 'Total Questions',
                        count: 0,
                        icon: LineIcons.lightbulb,
                      );
                    }
                    if (snap.hasError) {
                      return const DashboardCard(
                        info: 'Total Questions',
                        count: 0,
                        icon: LineIcons.lightbulb,
                      );
                    }
                    return DashboardCard(info: 'Total Questions', count: snap.data, icon: LineIcons.lightbulb);
                  },
                ),
                FutureBuilder(
                  future: _categories,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) {
                      return const DashboardCard(
                        info: 'Total Categories',
                        count: 0,
                        icon: CupertinoIcons.grid,
                      );
                    }
                    if (snap.hasError) return const DashboardCard(info: 'Total Categories', count: 0, icon: CupertinoIcons.grid);
                    return DashboardCard(info: 'Total Categories', count: snap.data, icon: CupertinoIcons.grid);
                  },
                ),
                FutureBuilder(
                  future: _quizes,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) return const DashboardCard(info: 'Total Quizzes', count: 0, icon: LineIcons.list);
                    if (snap.hasError) return const DashboardCard(info: 'Total Quizzes', count: 0, icon: LineIcons.list);
                    return DashboardCard(info: 'Total Quizzes', count: snap.data, icon: LineIcons.list);
                  },
                ),
                FutureBuilder(
                  future: _featuredCategories,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) return const DashboardCard(info: 'Total Featured', count: 0, icon: LineIcons.bomb);
                    if (snap.hasError) return const DashboardCard(info: 'Total Featured', count: 0, icon: LineIcons.bomb);
                    return DashboardCard(info: 'Total Featured Categories', count: snap.data, icon: LineIcons.bomb);
                  },
                ),
                FutureBuilder(
                  future: _notifications,
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (!snap.hasData) return const DashboardCard(info: 'Total Notifications', count: 0, icon: LineIcons.bell);
                    if (snap.hasError) return const DashboardCard(info: 'Total Notifications', count: 0, icon: LineIcons.bell);
                    return DashboardCard(info: 'Total Notifications', count: snap.data, icon: LineIcons.bell);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
