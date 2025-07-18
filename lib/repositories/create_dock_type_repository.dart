import 'package:dio/dio.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/dock_type_model.dart';
import 'package:martinlog_web/services/http/http.dart';

import '../core/consts/endpoints.dart';

abstract interface class ICreateDockTypeRepository {
  Future<DockTypeModel> call(
      {required String name, required BranchOfficeModel branchOffice});
}

final class CreateDockTypeRepository implements ICreateDockTypeRepository {
  final IHttp http;
  final String urlBase;
  CreateDockTypeRepository({required this.http, required this.urlBase});
  @override
  Future<DockTypeModel> call(
      {required String name, required BranchOfficeModel branchOffice}) async {
    try {
      final response = await http.request<Response>(
          url: urlBase + Endpoints.dockType,
          method: HttpMethod.POST,
          body: {
            "name": name,
            "idBranchOffice": branchOffice.idBranchOffice,
          });

      return DockTypeModel.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
