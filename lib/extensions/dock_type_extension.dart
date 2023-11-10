import 'package:martinlog_web/enums/dock_type_enum.dart';

extension DockTypeExt on DockType {
  int get idDockType => switch (this) {
        DockType.EXPEDITION => 1,
        DockType.RECEIPT => 2,
        DockType.KAMIKAZE => 3
      };

  String get description => switch (this) {
        DockType.EXPEDITION => "Expedição",
        DockType.RECEIPT => "Recebimento",
        DockType.KAMIKAZE => "Camicado"
      };
}
