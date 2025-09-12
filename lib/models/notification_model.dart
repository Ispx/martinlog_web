import 'dart:convert';

class NotificationModel {
  int? idNotification;
  final int idNotificationType;
  final String title;
  final String body;
  final Map payload;
  final int targetIdCompany;
  final int targetIdBranchOffice;
  final int idUser;
  final bool viewed;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'idNotification': idNotification,
      'idNotificationType': idNotificationType,
      'title': title,
      'body': body,
      'payload': payload,
      'targetIdCompany': targetIdCompany,
      'targetIdBranchOffice': targetIdBranchOffice,
      'idUser': idUser,
      'viewed': viewed,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification: json['idNotification'] as int?,
      idNotificationType: json['idNotificationType'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] is String
          ? jsonDecode(json['payload'])
          : json['payload'] as Map,
      targetIdCompany: json['targetIdCompany'] as int,
      targetIdBranchOffice: json['targetIdBranchOffice'] as int,
      idUser: json['idUser'] as int,
      viewed: json['viewed'] as bool,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal() : null,
    );
  }

  NotificationModel({
    this.idNotification,
    required this.idNotificationType,
    required this.title,
    required this.body,
    required this.payload,
    required this.targetIdCompany,
    required this.targetIdBranchOffice,
    required this.idUser,
    required this.viewed,
    this.createdAt,
  });

  NotificationModel copyWith({bool? viewed}) {
    return NotificationModel(
      idNotificationType: idNotificationType,
      title: title,
      body: body,
      payload: payload,
      targetIdCompany: targetIdCompany,
      targetIdBranchOffice: targetIdBranchOffice,
      idUser: idUser,
      viewed: viewed ?? this.viewed,
    );
  }
}
