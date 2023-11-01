import 'package:martinlog_web/models/operation_model.dart';

abstract interface class ICreateOperationRepository {
  Future<OperationModel> call({
    required String dockCode,
    required String liscensePlate,
    required String description,
  });
}

class CreateOperationRepository implements ICreateOperationRepository{
  @override
  Future<OperationModel> call({required String dockCode, required String liscensePlate, required String description}) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
