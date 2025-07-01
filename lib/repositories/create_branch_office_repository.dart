import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class CreateBranchOfficeRepository {
  Future<BranchOfficeModel> call({required String name});
}

final class CreateBranchOfficeRepositoryImp
    implements CreateBranchOfficeRepository {
  final String urlBase;
  final Http http;
  CreateBranchOfficeRepositoryImp({required this.http, required this.urlBase});
  @override
  Future<BranchOfficeModel> call({required String name}) async {
    final response = await http.request(
      url: urlBase + Endpoints.branchOfficeCreate,
      body: {'name': name},
      method: HttpMethod.POST,
    );
    return BranchOfficeModel.fromJson(response.data);
  }
}
