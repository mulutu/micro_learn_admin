import 'package:app_admin/blocs/admin_bloc.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/pages/sign_in.dart';
import 'package:app_admin/tabs/ad_settings.dart';
import 'package:app_admin/tabs/categories.dart';
import 'package:app_admin/pages/change_password.dart';
import 'package:app_admin/tabs/notifications.dart';
import 'package:app_admin/tabs/questions.dart';
import 'package:app_admin/tabs/settings.dart';
import 'package:app_admin/tabs/users.dart';
import 'package:app_admin/services/auth_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../blocs/ads_bloc.dart';
import '../blocs/menu_controller.dart';
import '../blocs/settings_bloc.dart';
import '../components/responsive.dart';
import '../components/side_menu.dart';
import '../tabs/dashboard.dart';
import '../tabs/featured_categories.dart';
import '../tabs/quizzes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _list = <Widget>[
    const DashboardScreen(),
    const Categories(),
    const Quizzes(),
    const Questions(),
    const FeaturedCategories(),
    const Notifications(),
    const Users(),
    const AdSettings(),
    const Settings(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        context.read<SettingsBloc>().getSettingsData();
        context.read<AdsBloc>().getAdsData();
        debugPrint(context.read<AdminBloc>().userRole);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        pageController: _pageController,
      ),
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 56),
        child: _AppBar(
          scaffoldKey: _scaffoldKey,
        ),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //it takes 1/6 part of the screen
            Visibility(
              visible: Responsive.isDesktop(context),
              child: Expanded(
                  child: SideMenu(
                pageController: _pageController,
              )),
            ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: _list,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final String? userRole = context.watch<AdminBloc>().userRole;
    final String userRoleText = userRole != null && userRole == 'admin'
        ? 'Hi, Admin'
        : userRole != null && userRole == 'editor'
            ? 'Hi, Editor'
            : 'Hi, Tester';

    final double leadingWidth = Responsive.isDesktop(context) ? 20.0 : 50.0;

    // ignore: no_leading_underscores_for_local_identifiers
    _openChangePasswordDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return const Dialog(child: ChangePassword());
          });
    }

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: leadingWidth,
      title: Text(
        '${Config.appName} - Admin Panel ',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 19),
      ),
      leading: Visibility(
        visible: !Responsive.isDesktop(context),
        child: IconButton(
          onPressed: () {
            context.read<MenuControllerBloc>().controlMenu(scaffoldKey);
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        PopupMenuButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(LineIcons.userCircle),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(userRoleText),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ],
          ),
          itemBuilder: (context) {
            return <PopupMenuItem>[
              const PopupMenuItem(
                value: 'password',
                child: Text('Change Password'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              )
            ];
          },
          onSelected: (value) async {
            if (value == 'password') {
              if (userRole != null && userRole == 'admin' || userRole == 'editor') {
                _openChangePasswordDialog();
              } else {
                openCustomDialog(context, Config.testingDialog, '');
              }
            } else if (value == 'logout') {
              await AuthService().adminLogout().then((value) async =>
                  await context.read<AdminBloc>().clearLocalData().then((value) => NextScreen().nextScreenReplace(context, const SignInPage())));
            }
          },
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }
}
