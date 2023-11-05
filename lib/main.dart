import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:martinlog_web/app.dart';
import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/repositories/auth_repository.dart';
import 'package:martinlog_web/repositories/cancel_operation_repository.dart';
import 'package:martinlog_web/repositories/create_company_repository.dart';
import 'package:martinlog_web/repositories/create_dock_repositoy.dart';
import 'package:martinlog_web/repositories/create_operation_repository.dart';
import 'package:martinlog_web/repositories/get_companies_repository.dart';
import 'package:martinlog_web/repositories/get_company_repositoy.dart';
import 'package:martinlog_web/repositories/get_docks_repository.dart';
import 'package:martinlog_web/repositories/get_operation_repository.dart';
import 'package:martinlog_web/repositories/get_operations_repository.dart';
import 'package:martinlog_web/repositories/update_progress_operation_repository.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';

void main() async {
  await EnvConfig().read(const String.fromEnvironment("DEV"));
  Intl.defaultLocale = 'pt_BR';
  initializeDateFormatting('pt_BR', null);

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
      i.addFactory<CreateCompanyRepository>(
        () => CreateCompanyRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );

      i.addFactory<CreateDockRepository>(
        () => CreateDockRepository(
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
      i.addFactory<UpdateProgressOperationRepository>(
        () => UpdateProgressOperationRepository(
          http: i.get<Http>(),
          urlBase: EnvConfig.urlBase,
        ),
      );

      i.addSingleton<AuthViewModel>(
        () => AuthViewModel(authRepository: i.get<AuthRepository>()),
      );
      i.addSingleton<CompanyViewModel>(
        () => CompanyViewModel(
            getCompaniesRepository: i.get<GetCompaniesRepository>(),
            getCompanyRepository: i.get<GetCompanyRepository>(),
            createCompanyRepository: i.get<CreateCompanyRepository>()),
      );
      i.addSingleton<DockViewModel>(
        () => DockViewModel(
            getDocksRepository: i.get<GetDocksRepository>(),
            createDockRepository: i.get<CreateDockRepository>()),
      );
      i.addSingleton<OperationViewModel>(
        () => OperationViewModel(
            cancelOperationRepository: i.get<CancelOperationRepository>(),
            createOperationRepository: i.get<CreateOperationRepository>(),
            getOperationsRepository: i.get<GetOperationsRepository>(),
            getOperationRepository: i.get<GetOperationRepository>(),
            updateProgressOperationRepository:
                i.get<UpdateProgressOperationRepository>()),
      );

      return i;
    },
  );
  runApp(const App());
}
