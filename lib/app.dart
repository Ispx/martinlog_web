import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/models/auth_model.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/style/theme/app_theme.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/views/mobile/auth_view.dart';
import 'package:martinlog_web/views/mobile/dashboard_view.dart';
import 'package:martinlog_web/views/mobile/menu_view.dart';
import 'package:martinlog_web/views/mobile/operation/views/operation_view_details_mobile.dart';
import 'package:martinlog_web/views/mobile/operation/views/operation_view_mobile.dart';
import 'package:martinlog_web/views/mobile/password_recovery.dart';
import 'package:martinlog_web/views/web/auth_view.dart';
import 'package:martinlog_web/views/web/bind_branch_office_view.dart';
import 'package:martinlog_web/views/web/company_view.dart';
import 'package:martinlog_web/views/web/dashboard_view.dart';
import 'package:martinlog_web/views/web/dock_view.dart';
import 'package:martinlog_web/views/web/menu_view.dart';
import 'package:martinlog_web/views/web/operation_view.dart';
import 'package:martinlog_web/views/web/password_recovery_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
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
          routes: kIsWeb
              ? {
                  Routes.auth: (context) => const AuthView(),
                  Routes.operation: (context) => const OperationView(),
                  Routes.company: (context) => const CompanyView(),
                  Routes.dock: (context) => const DockView(),
                  Routes.dashboard: (context) => const DashboardView(),
                  Routes.menu: (context) => const MenuView(),
                  Routes.passwordRecovery: (context) =>
                      const PassswordRecoveryView(),
                  Routes.bindBranchOffice: (context) =>
                      const BindBranchOfficeView(),
                }
              : {
                  Routes.auth: (context) => const AuthViewMobile(),
                  Routes.operation: (context) => const OperationViewMobile(),
                  Routes.company: (context) => const CompanyView(),
                  Routes.dock: (context) => const DockView(),
                  Routes.dashboard: (context) => const DashboardViewMobile(),
                  Routes.menu: (context) => const MenuViewMobile(),
                  Routes.passwordRecovery: (context) =>
                      const PasswordRecoveryMobileView(),
                  Routes.operationDetails: (context) =>
                      const OperationViewDetailsMobile(),
                  Routes.bindBranchOffice: (context) =>
                      const BindBranchOfficeView(),
                },
          onGenerateRoute: (settings) {
            if (isAuthenticated) return null;
            return MaterialPageRoute(
              builder: (context) =>
                  kIsWeb ? const AuthView() : const AuthViewMobile(),
            );
          },
        );
      },
    );
  }
}

bool get isAuthenticated {
  try {
    final authModel = simple.get<AuthModel>();
    return authModel.accessToken.isNotEmpty;
  } catch (_) {
    return false;
  }
}
