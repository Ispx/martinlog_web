import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/company_model.dart';

abstract interface class IGetCompanyRepository {
  Future<CompanyModel> call();
}

class GetCompanyRepository implements IGetCompanyRepository {
  final IHttp http;
  final String urlBase;
  GetCompanyRepository({required this.http, required this.urlBase});
  @override
  Future<CompanyModel> call() async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.company,
        method: HttpMethod.GET,
      );
      return CompanyModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
