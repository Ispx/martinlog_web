import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';

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
        DockType.EXPEDITION =>
          simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated == 11
              ? "DL/Camicado"
              : "DL",
        DockType.RECEIPT =>
          simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated == 11
              ? "Receb. Caixaria/Container"
              : "Recebimento",
        DockType.KAMIKAZE =>
          simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated == 11
              ? "Exp. Caixaria"
              : "Camicado",
        DockType.TRANSFER =>
          simple.get<BranchOfficeViewModelImpl>().idBranchOfficeActivated == 11
              ? "Exp. Cabide"
              : "Transferência",
        DockType.REVERSE => "Reversa",
      };
}
