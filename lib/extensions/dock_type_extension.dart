import 'package:martinlog_web/enums/dock_type_enum.dart';

extension DockTypeExt on DockType {
  int get idDockType => switch (this) {
        DockType.UNDEFINED => -1,
        DockType.EXPEDITION => 1,
        DockType.RECEIPT => 2,
        DockType.KAMIKAZE => 3,
        DockType.TRANSFER => 4,
        DockType.REVERSE => 5,
      };

  String get description => switch (this) {
        DockType.UNDEFINED => "",
        DockType.EXPEDITION => "DL",
        DockType.RECEIPT => "Recebimento",
        DockType.KAMIKAZE => "Camicado",
        DockType.TRANSFER => "Transferência",
        DockType.REVERSE => "Reverso",
      };
}
