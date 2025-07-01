import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class GetBranchOfficeRepository {
  Future<List<BranchOfficeModel>> call();
}

final class GetBranchOfficeRepositoryImp implements GetBranchOfficeRepository {
  final String urlBase;
  final Http http;
  GetBranchOfficeRepositoryImp({required this.http, required this.urlBase});
  @override
  Future<List<BranchOfficeModel>> call() async {
    final response = await http.request(
      url: urlBase + Endpoints.branchOfficeAll,
      method: HttpMethod.GET,
    );
    var result = List<BranchOfficeModel>.from(
        response.data.map((e) => BranchOfficeModel.fromJson(e)).toList());
    return result;
  }
}
