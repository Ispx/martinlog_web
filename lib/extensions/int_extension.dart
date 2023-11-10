import 'package:martinlog_web/enums/dock_type_enum.dart';

import '../enums/profile_type_enum.dart';

extension IntExt on int {
  ProfileTypeEnum getProfile() => switch (this) {
        1 => ProfileTypeEnum.ADM,
        2 => ProfileTypeEnum.MASTER,
        _ => throw Exception("$this is invalid profile")
      };
  DockType getDockType() => switch (this) {
        1 => DockType.EXPEDITION,
        2 => DockType.RECEIPT,
        3 => DockType.KAMIKAZE,
        _ => throw Exception("$this is invalid dock")
      };
}
