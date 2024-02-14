class Endpoints {
  static final Endpoints _i = Endpoints._();
  Endpoints._();
  factory Endpoints() => _i;
  static const auth = "/login";
  static const passwordRecoveryStart = "/password/start";
  static const passwordRecoveryComplete = "/password/complete";
  static const company = "/company";
  static const companyAll = "$company/all";
  static const dock = "/dock";
  static const user = "/user";
  static const userAll = "$user/all";
  static const dockAll = "$dock/all";
  static const operation = "/operation";
  static const operationAll = "$operation/all";
  static const operationCancel = "$operation/cancel/<operationKey>";
  static const operationUpdate = "$operation/<operationKey>";
  static const operationUploadFile = "$operation/<operationKey>/upload/file";
}
