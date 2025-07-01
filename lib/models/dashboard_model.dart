class DashboardModel {
  final int total;
  final int today;
  final int inProgress;
  final int idDockTpe;

  DashboardModel({
    required this.total,
    required this.inProgress,
    required this.today,
    required this.idDockTpe,
  });
  factory DashboardModel.fromJson(Map map) {
    return DashboardModel(
      idDockTpe: map['idDockTpe'],
      total: map['total'],
      today: map['today'],
      inProgress: map['inProgress'],
    );
  }
}
