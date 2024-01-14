import 'package:martinlog_web/enums/operation_status_enum.dart';

extension OperationStatusExt on OperationStatusEnum {
  int get idOperationStatus => switch (this) {
        OperationStatusEnum.UNDEFINED => -1,
        OperationStatusEnum.CREATED => 1,
        OperationStatusEnum.IN_PROGRESS => 2,
        OperationStatusEnum.CANCELED => 3,
        OperationStatusEnum.FINISHED => 4,
      };

  String get description => switch (this) {
        OperationStatusEnum.UNDEFINED => "",
        OperationStatusEnum.CREATED => "Criado",
        OperationStatusEnum.IN_PROGRESS => "Em progresso",
        OperationStatusEnum.CANCELED => "Cancelado",
        OperationStatusEnum.FINISHED => "Finalizado",
      };
}
