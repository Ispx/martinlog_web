import 'package:martinlog_web/enums/event_type_enum.dart';

extension EventTypeExt on EventTypeEnum {
  String get description => switch (this) {
        EventTypeEnum.OPERATION_FINISHED => 'operation_finished',
        EventTypeEnum.OPERATION_UPDATED => 'operation_updated',
        EventTypeEnum.OPERATION_CREATED => 'operation_created'
      };
}
