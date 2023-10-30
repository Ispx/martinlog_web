import 'package:martinlog_web/enums/profile_type_enum.dart';

extension ProfileTypeExt on ProfileTypeEnum {
  int get idProfileType => switch (this) {
        ProfileTypeEnum.ADM => 1,
        ProfileTypeEnum.MASTER => 2,
      };

  String get description => switch (this) {
        ProfileTypeEnum.ADM => "Admistrador",
        ProfileTypeEnum.MASTER => "Master",
      };
}
