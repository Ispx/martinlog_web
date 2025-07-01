import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class UnLinkCompanyToBranchOfficeRepository {
  Future<void> call({required int idCompany, required int idBranchOffice});
}

final class UnLinkCompanyToBranchOfficeRepositoryImp
    implements UnLinkCompanyToBranchOfficeRepository {
  final String urlBase;
  final Http http;
  UnLinkCompanyToBranchOfficeRepositoryImp(
      {required this.http, required this.urlBase});
  @override
  Future<void> call(
      {required int idCompany, required int idBranchOffice}) async {
    await http.request(
      url: urlBase + Endpoints.branchOfficeCompanyUnLink,
      body: {
        'idCompany': idCompany,
        "idBranchOffice": idBranchOffice,
      },
      method: HttpMethod.POST,
    );
  }
}
