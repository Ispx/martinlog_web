import 'package:martinlog_web/extensions/string_extension.dart';

class CompanyModel {
  int idCompany;

  String socialRason;
  String fantasyName;
  String cnpj;
  String ownerName;
  String ownerCpf;
  String telephone;
  String zipcode;
  String streetNumber;
  String? streetComplement;
  DateTime? createdAt;

  CompanyModel({
    required this.idCompany,
    required this.socialRason,
    required this.fantasyName,
    required this.cnpj,
    required this.ownerName,
    required this.ownerCpf,
    required this.telephone,
    required this.zipcode,
    required this.streetNumber,
    required this.streetComplement,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'socialRason': socialRason,
      'fantasyName': fantasyName,
      'cnpj': cnpj,
      'ownerName': ownerName,
      'ownerCpf': ownerCpf,
      'telephone': telephone,
      'zipcode': zipcode,
      'streetNumber': streetNumber,
      'streetComplement': streetComplement,
      'createdAt': createdAt?.toString(),
    };
  }

  factory CompanyModel.fromJson(Map<String, dynamic> map) {
    return CompanyModel(
      idCompany: map['idCompany'],
      socialRason: map['socialRason'],
      fantasyName: map['fantasyName'],
      cnpj: map['cnpj'],
      ownerName: map['ownerName'],
      ownerCpf: map['ownerCpf'],
      telephone: map['telephone'],
      zipcode: map['zipcode'],
      streetNumber: map['streetNumber'],
      streetComplement: map['streetComplement'],
      createdAt: map['createdAt'] != null
          ? map['createdAt'].toString().parseToDateTime()!
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "socialRason": socialRason,
        "fantasyName": fantasyName,
        "cnpj": cnpj,
        "ownerName": ownerName,
        "ownerCpf": ownerCpf,
        "telephone": telephone,
        "zipcode": zipcode,
        "streetNumber": streetNumber,
        "streetComplement": streetComplement,
        "createdAt": createdAt.toString(),
      };

  CompanyModel copyWith({
    String? socialRason,
    String? fantasyName,
    String? ownerName,
    String? ownerCpf,
    String? telephone,
    String? zipcode,
    String? streetNumber,
    String? streetComplement,
  }) {
    return CompanyModel(
      idCompany: idCompany,
      socialRason: socialRason ?? this.socialRason,
      fantasyName: fantasyName ?? this.fantasyName,
      cnpj: cnpj,
      ownerName: ownerName ?? this.ownerName,
      ownerCpf: ownerCpf ?? this.ownerCpf,
      telephone: telephone ?? this.telephone,
      zipcode: zipcode ?? this.zipcode,
      streetNumber: streetNumber ?? this.streetNumber,
      streetComplement: streetComplement ?? this.streetComplement,
      createdAt: createdAt,
    );
  }
}
