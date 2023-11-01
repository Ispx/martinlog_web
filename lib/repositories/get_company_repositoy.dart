import 'package:martinlog_web/models/company_model.dart';

abstract interface class IGetCompanyRepository {
  Future<CompanyModel> call();
}

class GetCompanyRepository implements IGetCompanyRepository {
  @override
  Future<CompanyModel> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
