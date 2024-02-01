import 'package:get/get_utils/get_utils.dart';
import 'package:martinlog_web/extensions/string_extension.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/models/dock_model.dart';

class OperationModel {
  String operationKey;
  DockModel? dockModel;
  CompanyModel companyModel;

  int idUser;
  String liscensePlate;
  int progress;
  int idOperationStatus;
  DateTime createdAt;
  DateTime? finishedAt;
  String? description;
  OperationModel({
    required this.operationKey,
    this.dockModel,
    required this.companyModel,
    required this.idUser,
    required this.liscensePlate,
    required this.progress,
    required this.idOperationStatus,
    required this.createdAt,
    this.finishedAt,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationKey': operationKey,
      'dock': dockModel?.toJson(),
      'company': companyModel.toJson(),
      'idUser': idUser,
      'liscensePlate': liscensePlate,
      'progress': progress,
      'idOperationStatus': idOperationStatus,
      'createdAt': createdAt.toString().parseToDateTime(),
      'finishedAt': finishedAt?.toString().parseToDateTime(),
      'description': description,
    };
  }

  factory OperationModel.fromJson(Map data) {
    return OperationModel(
      operationKey: data['operationKey'],
      companyModel: CompanyModel.fromJson(data['company']),
      idUser: data['idUser'],
      liscensePlate: data['liscensePlate'],
      dockModel: data['dock'] != null ? DockModel.fromJson(data['dock']) : null,
      progress: data['progress'],
      idOperationStatus: data['idOperationStatus'],
      createdAt: data['createdAt'].toString().parseToDateTime()!,
      finishedAt: data['finishedAt'] != null
          ? data['finishedAt'].toString().parseToDateTime()!
          : null,
      description: data['description'],
    );
  }

  OperationModel copyWith({
    int? progress,
    int? idOperationStatus,
    DateTime? finishedAt,
    DockModel? dockModel,
  }) {
    return OperationModel(
      operationKey: operationKey,
      dockModel: dockModel ?? this.dockModel,
      companyModel: companyModel,
      idUser: idUser,
      liscensePlate: liscensePlate,
      progress: progress ?? this.progress,
      idOperationStatus: idOperationStatus ?? this.idOperationStatus,
      createdAt: createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      description: description,
    );
  }
}
