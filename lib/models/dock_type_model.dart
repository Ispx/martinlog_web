class DockTypeModel {
  final int idDockType;
  final String name;
  final int idBranchOffice;
  final bool status;
  DockTypeModel({
    required this.idDockType,
    required this.name,
    required this.idBranchOffice,
    required this.status,
  });

  factory DockTypeModel.fromJson(Map map) {
    return DockTypeModel(
      idDockType: map['idDockType'],
      name: map['name'],
      idBranchOffice: map['idBranchOffice'],
      status: map['status'],
    );
  }
}
