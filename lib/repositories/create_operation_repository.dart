import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/operation_model.dart';

abstract interface class ICreateOperationRepository {
  Future<OperationModel> call({
    required CompanyModel companyModel,
    required String dockCode,
    required String liscensePlate,
    required String description,
    required String? route,
    required String? place,
  });
}

class CreateOperationRepository implements ICreateOperationRepository {
  final IHttp http;
  final String urlBase;
  CreateOperationRepository({required this.http, required this.urlBase});
  @override
  Future<OperationModel> call({
    required CompanyModel companyModel,
    required String dockCode,
    required String liscensePlate,
    required String description,
    required String? route,
    required String? place,
  }) async {
    try {
      final response = await http.request<Response>(
          url: urlBase + Endpoints.operation,
          method: HttpMethod.POST,
          body: {
            "dockCode": dockCode,
            "liscensePlate": liscensePlate,
            "description": description,
            "route": route,
            "place":place,
          },
          headers: {
            'IdCompany': companyModel.idCompany,
          });
      return OperationModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
