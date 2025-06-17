import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';
import 'package:martinlog_web/view_models/dashboard_view_model.dart';
import 'package:martinlog_web/view_models/dock_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidgetMobile extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Widget content;
  final List<Widget>? actions;
  final Widget? prefix;
  final bool isLoading;

  const AppBarWidgetMobile({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.content,
    this.isLoading = false,
    this.actions,
    this.prefix,
  });

  List<BranchOfficeModel> get branchs =>
      simple.get<AuthViewModel>().authModel?.idProfile.getProfile() ==
              ProfileTypeEnum.MASTER
          ? simple.get<BranchOfficeViewModelImpl>().branchs
          : simple.get<CompanyViewModel>().companyModel?.branchOffices ?? [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.padding * 2),
            child: Row(
              children: [
                if (prefix != null) prefix!,
                Text(
                  title,
                  style: AppTextStyle.displayLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  width: AppSize.padding * 2,
                ),
                Container(
                  height: 25,
                  width: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  width: AppSize.padding * 2,
                ),
                Expanded(
                  child: Obx(
                    () {
                      return Row(
                        children: [
                          SizedBox(
                            width: 25.w,
                            child: ManagerBranchOfficeWidget(
                              branchs: branchs,
                              onSelected: (BranchOfficeModel b) {
                                simple
                                    .get<BranchOfficeViewModelImpl>()
                                    .switchBranchOffice(b);
                                simple
                                    .get<DashboardViewModel>()
                                    .fetchDashboard();
                                simple.get<DockViewModel>().getAll();
                                simple
                                    .get<CompanyViewModel>()
                                    .getAllCompanies();
                                simple.get<OperationViewModel>().getAll();
                              },
                              value: branchs
                                  .where((e) =>
                                      e.idBranchOffice ==
                                      simple
                                          .get<BranchOfficeViewModelImpl>()
                                          .branchOfficeActivated
                                          .value
                                          .idBranchOffice)
                                  .firstOrNull,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async =>
                      await simple.get<AuthViewModel>().loggout(),
                  icon: const Icon(
                    Icons.exit_to_app,
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 6,
            child: isLoading
                ? LinearProgressIndicator(
                    color: context.appTheme.secondColor,
                    backgroundColor: context.appTheme.greyColor,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class ManagerBranchOfficeWidget extends StatefulWidget {
  final BranchOfficeModel? value;
  final List<BranchOfficeModel> branchs;
  final Function(BranchOfficeModel b) onSelected;
  const ManagerBranchOfficeWidget({
    super.key,
    required this.value,
    required this.branchs,
    required this.onSelected,
  });

  @override
  State<ManagerBranchOfficeWidget> createState() =>
      _ManagerBranchOfficeWidgetState();
}

class _ManagerBranchOfficeWidgetState extends State<ManagerBranchOfficeWidget> {
  BranchOfficeModel? branchOfficeModelSelected;
  List<DropdownMenuItem<BranchOfficeModel>> get menuItems =>
      widget.branchs.map((e) {
        return DropdownMenuItem<BranchOfficeModel>(
          value: e,
          child: Text(
            e.name,
            style: AppTextStyle.displayLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        );
      }).toList();
  @override
  void initState() {
    branchOfficeModelSelected = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: menuItems,
      value: branchOfficeModelSelected,
      underline: const SizedBox.shrink(),
      onChanged: (e) {
        if (e != null) {
          widget.onSelected.call(e);
        }
        branchOfficeModelSelected = e;
        setState(() {});
      },
    );
  }
}
