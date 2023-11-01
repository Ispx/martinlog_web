import 'package:martinlog_web/models/company_model.dart';

abstract interface class IGetCompaniesRepository {
  Future<List<CompanyModel>> call();
}

class GetCompaniesRepository implements IGetCompaniesRepository {
  @override
  Future<List<CompanyModel>> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
