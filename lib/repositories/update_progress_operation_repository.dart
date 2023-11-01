import 'package:martinlog_web/models/operation_model.dart';

abstract interface class IUpdateProgressOperationRepository {
  Future<OperationModel> call(
      {required String operationKey, required int progress});
}

class UpdateProgressOperationRepository
    implements IUpdateProgressOperationRepository {
  @override
  Future<OperationModel> call(
      {required String operationKey, required int progress}) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
