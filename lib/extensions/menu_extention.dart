import 'package:martinlog_web/state/menu_state.dart';

extension MenuExt on MenuEnum {
  String get title => switch (this) {
        MenuEnum.Operations => "Operações",
        MenuEnum.Dashboard => "Dashboard",
        MenuEnum.Company => "Transportadoras",
        MenuEnum.Dock => "Docas"
      };
}
