import 'dart:ui';
import 'package:app_admin/pages/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blocs/admin_bloc.dart';
import 'blocs/ads_bloc.dart';
import 'blocs/menu_controller.dart';
import 'blocs/page_controller.dart';
import 'blocs/settings_bloc.dart';
import 'configs/config.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuControllerBloc>(create: (context) => MenuControllerBloc()),
        ChangeNotifierProvider<PageViewController>(create: (context) => PageViewController()),
        ChangeNotifierProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        ChangeNotifierProvider<AdsBloc>(create: (context) => AdsBloc()),
        ChangeNotifierProvider<AdminBloc>(create: (context) => AdminBloc()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Admin Panel',
          scrollBehavior: TouchAndMouseScrollBehavior(),
          theme: ThemeData(
            primaryColor: Config.primaryColor,
            scaffoldBackgroundColor: Config.bgColor,
            canvasColor: Config.secondaryColor,
            useMaterial3: false,
            textTheme: GoogleFonts.poppinsTextTheme()
          ),
          home: const InitialPage(),
      ),
    );
  }
}



class TouchAndMouseScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}