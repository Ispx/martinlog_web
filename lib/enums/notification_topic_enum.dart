enum NotificationTopicsEnum {
  OPERATION_CREATED('operation_created'),
  OPERATION_UPDATED('operation_updated'),
  OPERATION_CANCELED('operation_canceled'),
  OPERATION_FINISHED('operation_finished');

  const NotificationTopicsEnum(this.description);
  final String description;
}
