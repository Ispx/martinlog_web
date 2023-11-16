import 'package:flutter/material.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/style/theme/app_theme.dart';
import 'package:martinlog_web/view_models/dashboard_view.dart';
import 'package:martinlog_web/views/auth_view.dart';
import 'package:martinlog_web/views/company_view.dart';
import 'package:martinlog_web/views/dock_view.dart';
import 'package:martinlog_web/views/operation_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:martinlog_web/components/banner_component.dart';
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
          primaryColor: Colors.greenAccent,
          primaryVariant: Colors.blueAccent,
          secondColor: Colors.blue,
          greenColor: Colors.grey,
          backgroundColor: Colors.white,
          iconColor: Colors.grey,
          buttonEnableColor: Colors.green,
          disableColor: Colors.grey,
          buttonDisableColor: Colors.grey,
          hintFieldColor: Colors.grey.shade300,
          borderColor: Colors.black,
          titleColor: Colors.black,
          greyColor: Colors.green,
          redColor: Colors.red,
        ).theme,
        initialRoute: Routes.auth,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('pt_BR'),
        routes: {
          Routes.auth: (context) => AuthView(),
          Routes.operation: (context) => OperationView(),
          Routes.company: (context) => CompanyView(),
          Routes.dock: (context) => DockView(),
          Routes.dashboard: (context) => DashboardView(),
        },
      );
    });
  }
}
