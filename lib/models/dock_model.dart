import 'package:martinlog_web/extensions/string_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';

class DockModel {
  String code;
  int idDockType;
  DateTime createdAt;
  bool isActive;
  String? operationKey;
  BranchOfficeModel? branchOfficeModel;
  DockModel({
    required this.code,
    required this.idDockType,
    required this.createdAt,
    this.isActive = true,
    this.operationKey,
    this.branchOfficeModel,
  });

  factory DockModel.fromJson(Map<String, dynamic> data) {
    return DockModel(
      code: data['code'],
      idDockType: data['idDockType'],
      createdAt: DateTime.parse(data['createdAt']),
      isActive: data['isActive'],
      operationKey: data['operationKey'],
      branchOfficeModel: data['branchOffice'] != null
          ? BranchOfficeModel.fromJson(data['branchOffice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "idDockType": idDockType,
      "createdAt": createdAt.toString().toString().parseToDateTime()!.toLocal(),
      "isActive": isActive,
      "operationKey": operationKey,
    };
  }

  DockModel copyWith(
      {int? idDockType,
      bool? isActive,
      String? operationKey,
      BranchOfficeModel? branchOfficeModel}) {
    return DockModel(
      code: code,
      idDockType: idDockType ?? this.idDockType,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      operationKey: operationKey ?? this.operationKey,
      branchOfficeModel: branchOfficeModel ?? this.branchOfficeModel,
    );
  }
}
