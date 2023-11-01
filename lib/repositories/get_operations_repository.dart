import 'package:martinlog_web/models/operation_model.dart';

abstract interface class IGetOperationsRepository {
  Future<List<OperationModel>> call(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status});
}

class GetOperationsRepository implements IGetOperationsRepository {
  @override
  Future<List<OperationModel>> call(
      {DateTime? dateFrom, DateTime? dateUntil, List<int>? status}) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
