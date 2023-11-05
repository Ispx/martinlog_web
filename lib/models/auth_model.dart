class AuthModel {
  final int idUser;
  int idCompany;
  final int idProfile;
  final String document;
  final String fullname;
  final String email;
  final String accessToken;
  AuthModel({
    required this.idUser,
    required this.idCompany,
    required this.idProfile,
    required this.document,
    required this.fullname,
    required this.email,
    required this.accessToken,
  });

  void switchCompany(int idCompany) => this.idCompany = idCompany;

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
