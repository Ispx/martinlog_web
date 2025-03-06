import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class LinkCompanyToBranchOfficeRepository {
  Future<void> call({required int idCompany, required int idBranchOffice});
}

final class LinkCompanyToBranchOfficeRepositoryImp
    implements LinkCompanyToBranchOfficeRepository {
  final String urlBase;
  final Http http;
  LinkCompanyToBranchOfficeRepositoryImp(
      {required this.http, required this.urlBase});
  @override
  Future<void> call(
      {required int idCompany, required int idBranchOffice}) async {
    await http.request(
      url: urlBase + Endpoints.branchOfficeCompanyLink,
      body: {
        'idCompany': idCompany,
        "idBranchOffice": idBranchOffice,
      },
      method: HttpMethod.POST,
    );
  }
}
