import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';
import 'package:martinlog_web/models/company_model.dart';

abstract interface class ICreateCompanyRepository {
  Future<CompanyModel> call(CompanyModel companyModel);
}

class CreateCompanyRepository implements ICreateCompanyRepository {
  final String urlBase;
  final Http http;
  CreateCompanyRepository({required this.http, required this.urlBase});
  @override
  Future<CompanyModel> call(CompanyModel companyModel) async {
    try {
      final response = await http.request<Response>(
          url: Endpoints.company, method: HttpMethod.PUT);
      return CompanyModel.fromJson(jsonDecode(response.data));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
