import '../enums/profile_type_enum.dart';

extension IntExt on int {
  ProfileTypeEnum? getProfile() => switch (this) {
        1 => ProfileTypeEnum.ADM,
        2 => ProfileTypeEnum.MASTER,
        _ => null
      };
}
