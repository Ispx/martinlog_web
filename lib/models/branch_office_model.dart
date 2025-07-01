class BranchOfficeModel {
  final int idBranchOffice;
  final String name;

  BranchOfficeModel({required this.idBranchOffice, required this.name});

  factory BranchOfficeModel.fromJson(Map map) {
    return BranchOfficeModel(
      idBranchOffice: map['idBranchOffice'],
      name: map['name'],
    );
  }
}
