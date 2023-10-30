import 'package:martinlog_web/models/dock_model.dart';

abstract interface class IGetDocksRepository {
  Future<List<DockModel>> call();
}

class GetDocksRepository implements IGetDocksRepository {
  
  @override
  Future<List<DockModel>> call() {
    // TODO: implement call
    throw UnimplementedError();
  }
}
