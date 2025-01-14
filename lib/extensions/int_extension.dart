import 'package:martinlog_web/enums/dock_type_enum.dart';
import 'package:martinlog_web/enums/operation_status_enum.dart';

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
        4 => DockType.TRANSFER,
        5 => DockType.REVERSE,
        _ => throw Exception("$this is invalid dock")
      };
  OperationStatusEnum getOperationStatus() => switch (this) {
        1 => OperationStatusEnum.CREATED,
        2 => OperationStatusEnum.IN_PROGRESS,
        3 => OperationStatusEnum.CANCELED,
        4 => OperationStatusEnum.FINISHED,
        _ => throw Exception("$this is invalid operation status")
      };
}
