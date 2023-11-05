import 'dart:convert';
import 'package:http/http.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/company_model.dart';

abstract interface class IGetCompaniesRepository {
  Future<List<CompanyModel>> call();
}

class GetCompaniesRepository implements IGetCompaniesRepository {
  final IHttp http;
  final String urlBase;
  GetCompaniesRepository({required this.http, required this.urlBase});
  @override
  Future<List<CompanyModel>> call() async {
    try {
      final response = await http.request<Response>(
        url: urlBase + Endpoints.companyAll,
        method: HttpMethod.GET,
      );
      return jsonDecode(response.body)
          .map((e) => CompanyModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
