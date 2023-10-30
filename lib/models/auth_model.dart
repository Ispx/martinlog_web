class AuthModel {
  int idUser;
  int idCompany;
  int idProfile;
  String document;
  String fullname;
  String email;
  String accessToken;
  AuthModel({
    required this.idUser,
    required this.idCompany,
    required this.idProfile,
    required this.document,
    required this.fullname,
    required this.email,
    required this.accessToken,
  });

  factory AuthModel.fromJson(Map data) {
    return AuthModel(
      idUser: data['idUser'],
      idCompany: data['idCompany'],
      idProfile: data['idProfile'],
      document: data['document'],
      email: data['email'],
      fullname: data['fullname'],
      accessToken: data['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'idCompany': idCompany,
      'idProfile': idProfile,
      'document': document,
      'email': email,
    };
  }
}
