import 'package:martinlog_web/extensions/string_extension.dart';
import 'package:martinlog_web/models/company_model.dart';

class UserModel {
  final String fullname;
  final String document;

  final String email;
  final int idProfile;
  final bool isActive;
  final DateTime createdAt;
  final CompanyModel companyModel;

  UserModel({
    required this.fullname,
    required this.document,
    required this.email,
    required this.idProfile,
    required this.isActive,
    required this.createdAt,
    required this.companyModel,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      fullname: data['fullname'],
      document: data['document'],
      email: data['email'],
      isActive: data['isActive'],
      idProfile: data['idProfile'],
      createdAt: data['createdAt'].toString().parseToDateTime()!,
      companyModel: CompanyModel.fromJson(data['company']),
    );
  }

  UserModel copyWith({
    String? fullname,
    String? document,
    String? email,
    int? idProfile,
    bool? isActive,
  }) {
    return UserModel(
      fullname: fullname ?? this.fullname,
      document: document ?? this.document,
      email: email ?? this.email,
      idProfile: idProfile ?? this.idProfile,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      companyModel: companyModel,
    );
  }
}
