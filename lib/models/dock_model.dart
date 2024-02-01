import 'package:martinlog_web/extensions/string_extension.dart';

class DockModel {
  String code;
  int idDockType;
  DateTime createdAt;
  bool isActive;
  String? operationKey;
  DockModel({
    required this.code,
    required this.idDockType,
    required this.createdAt,
    this.isActive = true,
    this.operationKey,
  });

  factory DockModel.fromJson(Map<String, dynamic> data) {
    return DockModel(
      code: data['code'],
      idDockType: data['idDockType'],
      createdAt: DateTime.parse(data['createdAt']),
      isActive: data['isActive'],
      operationKey: data['operationKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "idDockType": idDockType,
      "createdAt": createdAt.toString().toString().parseToDateTime(),
      "isActive": isActive,
      "operationKey": operationKey,
    };
  }

  DockModel copyWith({
    int? idDockType,
    bool? isActive,
    String? operationKey,
  }) {
    return DockModel(
      code: code,
      idDockType: idDockType ?? this.idDockType,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      operationKey: operationKey ?? this.operationKey,
    );
  }
}
