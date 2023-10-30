import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/models/dock_model.dart';

abstract interface class ICreateDockRepository {
  Future<DockModel> call({required String code, required DockType dockType});
}

class CreateDockRepository implements ICreateDockRepository {
  @override
  Future<DockModel> call({required String code, required DockType dockType}) {
    // TODO: implement call
    throw UnimplementedError();
  }
}
