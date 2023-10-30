import 'package:martinlog_web/extensions/string_extension.dart';
import 'package:martinlog_web/models/dock_model.dart';

class OperationModel {
  String operationKey;
  int idDock;
  DockModel? dockModel;
  int idCompany;
  int idUser;
  String liscensePlate;
  int progress;
  int idOperationStatus;
  DateTime createdAt;
  DateTime? finishedAt;
  String? description;
  OperationModel({
    required this.operationKey,
    required this.idDock,
    this.dockModel,
    required this.idCompany,
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
      'idCompany': idCompany,
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
      idDock: data['idDock'],
      idCompany: data['idCompany'],
      idUser: data['idUser'],
      liscensePlate: data['liscensePlate'],
      progress: data['progress'],
      idOperationStatus: data['idOperationStatus'],
      createdAt: data['createdAt'],
      finishedAt: data['finishedAt'],
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
      idCompany: idCompany,
      idUser: idUser,
      liscensePlate: liscensePlate,
      progress: progress ?? this.progress,
      idOperationStatus: idOperationStatus ?? this.idOperationStatus,
      createdAt: createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      idDock: idDock,
      description: description,
    );
  }
}
