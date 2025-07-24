import 'package:martinlog_web/models/dock_type_model.dart';

class BranchOfficeModel {
  final int idBranchOffice;
  final String name;
  final List<DockTypeModel>? dockTypes;

  BranchOfficeModel(
      {required this.idBranchOffice, required this.name, this.dockTypes});

  factory BranchOfficeModel.fromJson(Map map) {
    final dockTypes = <DockTypeModel>[];
    if (map['dockTypes'] != null) {
      for (var json in map['dockTypes']) {
        dockTypes.add(DockTypeModel.fromJson(json));
      }
    }

    return BranchOfficeModel(
      idBranchOffice: map['idBranchOffice'],
      name: map['name'],
      dockTypes: dockTypes,
    );
  }
}
