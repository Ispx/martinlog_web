import 'package:flutter/material.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/style/theme/app_theme.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/views/dashboard_view.dart';
import 'package:martinlog_web/views/auth_view.dart';
import 'package:martinlog_web/views/company_view.dart';
import 'package:martinlog_web/views/dock_view.dart';
import 'package:martinlog_web/views/menu_view.dart';
import 'package:martinlog_web/views/operation_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/views/password_recovery_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: GoTo.navigatorState,
        scaffoldMessengerKey: scaffoldMessengerState,
        title: EnvConfig.appName,
        theme: AppThemeData(
          primaryColor: Utils.color("#D5DE23"),
          primaryVariant: Utils.color("#CFD022"),
          secondColor: Utils.color("#334359"),
          greenColor: Colors.green,
          backgroundColor: Utils.color("#F5F7FA"),
          iconColor: Colors.grey,
          buttonEnableColor: Utils.color("#D5DE23"),
          disableColor: Colors.grey,
          buttonDisableColor: Colors.grey,
          hintFieldColor: Utils.color("#5A789D"),
          borderColor: Utils.color("#5A789D"),
          titleColor: Colors.black,
          greyColor: Utils.color("#CCCCCC"),
          redColor: Colors.red,
        ).theme,
        initialRoute: Routes.auth,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('pt_BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        routes: {
          Routes.auth: (context) => const AuthView(),
          Routes.operation: (context) => const OperationView(),
          Routes.company: (context) => const CompanyView(),
          Routes.dock: (context) => const DockView(),
          Routes.dashboard: (context) => const DashboardView(),
          Routes.menu: (context) => const MenuView(),
          Routes.passwordRecovery: (context) => const PassswordRecoveryView(),
        },
      );
    });
  }
}
