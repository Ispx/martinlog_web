import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/consts/routes.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';

class UnauthorizedInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if ((err.response?.statusCode) == 401) {
      try {
        await simple.get<AuthViewModel>().autoLogin();
        BannerComponent(
          message: "Falha de conexão, tente novamente!",
          duration: const Duration(
            seconds: 3,
          ),
          backgroundColor: Colors.red,
        );
        super.onError(err, handler);
        return;
      } catch (e) {
        BannerComponent(
          message: "Sua sessão expirou!",
          duration: const Duration(
            seconds: 3,
          ),
          backgroundColor: Colors.red,
        );
        simple.reset();

        GoTo.removeAllAndGoTo(
          Routes.auth,
        );
      }

      return;
    }

    super.onError(err, handler);
  }
}
