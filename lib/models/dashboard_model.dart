class DashboardModel {
  final int idDockType;
  final int total;

  DashboardModel({required this.idDockType, required this.total});
  factory DashboardModel.fromJson(Map map) {
    return DashboardModel(
      idDockType: map['idDockTpe'],
      total: map['total'],
    );
  }
}
