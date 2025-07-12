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
  static const operation = '/operation';
  static const getOperation = '$operation/<operationKey>';
  static const operationPending = '$operation/pending/all';
  static const operationCancel = '$operation/<operationKey>/cancel';
  static const operationUpdate = '$operation/<operationKey>/update';
  static const operationUploadFile = '$operation/<operationKey>/upload';
  static const operationAll = '$operation/all';
  static const branchOfficeCreate = '/branch-office/create';
  static const branchOfficeAll = '/branch-office/all';
  static const branchOfficeCompanyLink = '/branch-office/company/link';
  static const branchOfficeCompanyUnLink = '/branch-office/company/unlink';

  static const branchOfficeCompanyLinked = '/branch-office/company/linked';
  static const dashboard = '/dashboard';
    static const dockType = "/dock-type";

}
