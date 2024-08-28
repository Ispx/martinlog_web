import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:martinlog_web/app.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/repositories/auth_repository.dart';
import 'package:martinlog_web/repositories/cancel_operation_repository.dart';
import 'package:martinlog_web/repositories/complete_password_recovery_repository.dart';
import 'package:martinlog_web/repositories/create_company_repository.dart';
import 'package:martinlog_web/repositories/create_operation_repository.dart';
import 'package:martinlog_web/repositories/create_user_repository.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/repositories/get_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operations_pending_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/repositories/get_users_repository.dart';
import 'package:martinlog_web/repositories/start_password_recovery_repository.dart';
import 'package:martinlog_web/repositories/update_operation_repository.dart';
import 'package:martinlog_web/repositories/update_user_repository.dart';
import 'package:martinlog_web/repositories/upload_file_operation_repository.dart';
import 'package:martinlog_web/repositories/upsert_dock_repositoy.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/menu_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/view_models/password_recovery_view_model.dart';
import 'package:martinlog_web/view_models/user_view_model.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

void main() async {
  var appToken = "AAeb308c57c9293e46a4c6891b1a419e030b3b74e2-NRMA";
  Config config = Config(
      accessToken: appToken,

      // Android specific option
      // Optional: Enable or disable collection of event data.
      analyticsEventEnabled: true,

      // iOS specific option
      // Optional: Enable or disable automatic instrumentation of WebViews.
      webViewInstrumentation: true,

      // Optional: Enable or disable reporting successful HTTP requests to the MobileRequest event type.
      networkErrorRequestEnabled: true,

      // Optional: Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
      networkRequestEnabled: true,

      // Optional: Enable or disable crash reporting.
      crashReportingEnabled: true,

      // Optional: Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
      interactionTracingEnabled: true,

      // Optional: Enable or disable capture of HTTP response bodies for HTTP error traces, and MobileRequestError events.
      httpResponseBodyCaptureEnabled: true,

      // Optional: Enable or disable agent logging.
      loggingEnabled: true,

      // Optional: Enable or disable print statements as Analytics Events.
      printStatementAsEventsEnabled: true,

      // Optional: Enable or disable automatic instrumentation of HTTP requests.
      httpInstrumentationEnabled: true);

  simple.startUp(
    (i) {
      i.addFactory<Http>(() => Http());
      i.addFactory<AuthRepository>(
        () => AuthRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<CancelOperationRepository>(
        () => CancelOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<UploadFileOperationRepository>(
        () => UploadFileOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<CreateCompanyRepository>(
        () => CreateCompanyRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );

      i.addFactory<UpsertDockRepository>(
        () => UpsertDockRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<CreateOperationRepository>(
        () => CreateOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetCompaniesRepository>(
        () => GetCompaniesRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetCompanyRepository>(
        () => GetCompanyRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetDocksRepository>(
        () => GetDocksRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetOperationRepository>(
        () => GetOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetOperationsRepository>(
        () => GetOperationsRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<UpdateOperationRepository>(
        () => UpdateOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<UpdateUserRepository>(
        () => UpdateUserRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<CreateUserRepository>(
        () => CreateUserRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetUsersRepository>(
        () => GetUsersRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<StartPasswordRecoveryRepository>(
        () => StartPasswordRecoveryRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<CompletePasswordRecoveryRepository>(
        () => CompletePasswordRecoveryRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addFactory<GetOperationsPedingRepository>(
        () => GetOperationsPedingRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );
      i.addSingleton<AuthViewModel>(
        () => AuthViewModel(
          authRepository: i.get<AuthRepository>(),
        ),
      );
      i.addSingleton<CompanyViewModel>(
        () => CompanyViewModel(
          getCompaniesRepository: i.get<GetCompaniesRepository>(),
          getCompanyRepository: i.get<GetCompanyRepository>(),
          createCompanyRepository: i.get<CreateCompanyRepository>(),
        ),
      );
      i.addSingleton<DockViewModel>(
        () => DockViewModel(
          getDocksRepository: i.get<GetDocksRepository>(),
          upsertDockRepository: i.get<UpsertDockRepository>(),
        ),
      );
      i.addSingleton<OperationViewModel>(
        () => OperationViewModel(
          uploadFileOperationRepository: i.get<UploadFileOperationRepository>(),
          cancelOperationRepository: i.get<CancelOperationRepository>(),
          createOperationRepository: i.get<CreateOperationRepository>(),
          getOperationsRepository: i.get<GetOperationsRepository>(),
          getOperationRepository: i.get<GetOperationRepository>(),
          updateOperationRepository: i.get<UpdateOperationRepository>(),
          getOperationsPedingRepository: i.get<GetOperationsPedingRepository>(),
        ),
      );
      i.addSingleton<UserViewModel>(
        () => UserViewModel(
          createUserRepository: i.get<CreateUserRepository>(),
          updateUserRepository: i.get<UpdateUserRepository>(),
          getUsersRepository: i.get<GetUsersRepository>(),
        ),
      );
      i.addSingleton<PasswordRecoveryViewModel>(
        () => PasswordRecoveryViewModel(
          startPasswordRecoveryRepository:
              i.get<StartPasswordRecoveryRepository>(),
          completePasswordRecoveryRepository:
              i.get<CompletePasswordRecoveryRepository>(),
        ),
      );
      i.addSingleton<DashboardViewModel>(
        () => DashboardViewModel(
          getOperationsRepository: i.get<GetOperationsRepository>(),
        ),
      );
      i.addSingleton<MenuViewModel>(
        () => MenuViewModel(),
      );
      return i;
    },
  );

  await NewrelicMobile.instance.start(config, () async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBojaKfglolWvClT-VwYW9QzU2RGKi_e9E",
        appId: "1:1062375327946:web:3ae61c6e184e8e75130c33",
        messagingSenderId: "1062375327946",
        projectId: "martinlog-web",
        storageBucket: 'martinlog-web.appspot.com',
        authDomain: "martinlog-web.firebaseapp.com",
        measurementId: "G-CWVH9LC3GF",
      ),
    );
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR', null);

    runApp(const App());
  });
}
