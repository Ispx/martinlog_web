import 'package:martinlog_web/models/operation_model.dart';

abstract interface class IGetOperationRepository {
  Future<OperationModel> call(String operationKey);
}

class GetOperationRepository implements IGetOperationRepository {
  @override
  Future<OperationModel> call(String operationKey) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
