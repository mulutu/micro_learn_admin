import 'package:app_admin/blocs/menu_controller.dart';
import 'package:app_admin/blocs/page_controller.dart';
import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/configs/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

const Map<int, List<dynamic>> itemList = {
  0: ['Dashboard', LineIcons.pieChart],
  1: ['Categories', CupertinoIcons.grid],
  2: ['Quizzes', LineIcons.list],
  3: ['Questions', LineIcons.lightbulb],
  4: ['Featured', LineIcons.bomb],
  5: ['Notifications', LineIcons.bell],
  6: ['Users', LineIcons.usersCog],
  7: ['Ads', CupertinoIcons.money_dollar],
  8: ['Settings', CupertinoIcons.settings],
};

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0.5,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(10),
              color: Colors.white,
              height: 130,
              child: Center(
                child: Image.asset(
                  Config.logo,
                  height: 80,
                  width: 140,
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                String title = itemList[index]![0];
                IconData icon = itemList[index]![1];
                return DrawerListTile(
                    title: title,
                    icon: icon,
                    index: index,
                    press: () {
                      context.read<PageViewController>().controllPage(pageController, index);
                      if (!Responsive.isDesktop(context)) {
                        Navigator.pop(context);
                      }
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.icon,
    required this.press,
    required this.index,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;
  final int index;

  @override
  Widget build(BuildContext context) {
    bool selected = context.watch<MenuControllerBloc>().selectedIndex == index ? true : false;
    return Ink(
      child: ListTile(
        tileColor: selected ? Theme.of(context).primaryColor : Colors.transparent,
        onTap: () {
          press();
          context.read<MenuControllerBloc>().setSeletedIndex(index);
        },
        horizontalTitleGap: 0.0,
        leading: Icon(
          icon,
          size: 20,
          color: selected ? Colors.white : Colors.blueGrey[800]!,
        ),
        title: Text(
          title,
          style: TextStyle(color: selected ? Colors.white : Colors.blueGrey[800], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
