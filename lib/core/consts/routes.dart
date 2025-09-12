class Routes {
  static final Routes _i = Routes._();
  Routes._();
  factory Routes() => _i;
  static const auth = "/login";
  static const passwordRecovery = "/password-recovery";
  static const menu = "/menu";
  static const company = "/company";
  static const dock = "/dock";
  static const operation = "/operation";
  static const operationDetails = "/operation-details/<operationKey>";
  static const dashboard = "/dashboard";
  static const bindBranchOffice = '/company/bind-branch-office';
}
