import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/widgets/dropbox_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidget extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Widget content;
  final List<Widget>? actions;
  final bool isLoading;

  const AppBarWidget(
      {super.key,
      required this.title,
      required this.backgroundColor,
      required this.content,
      this.isLoading = false,
      this.actions});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 13.h,
      color: widget.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.padding * 2),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyle.displayLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Obx(() {
                        final branchName = simple
                            .get<BranchOfficeViewModelImpl>()
                            .branchOfficeActivated
                            .value
                            .name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text.rich(
                            TextSpan(
                              text: 'Filial: ',
                              children: [
                                TextSpan(
                                  text: branchName.isEmpty
                                      ? 'Não selecionada'
                                      : branchName,
                                  style: AppTextStyle.displaySmall(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            style:
                                AppTextStyle.displaySmall(context).copyWith(),
                          ),
                        );
                      }),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: false,
                          child: SizedBox(
                            width: 15.w,
                            child: const BranchOfficeManagerWidget(),
                          ),
                        ),
                        SizedBox(
                          width: AppSize.padding * 4,
                        ),
                        CircleAvatar(
                          backgroundColor: context.appTheme.secondColor,
                          child: Text(
                            Utils.getInitials(
                              simple.get<AuthViewModel>().authModel!.fullname,
                            ),
                            style: AppTextStyle.displayMedium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: AppSize.padding,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              simple.get<AuthViewModel>().authModel!.fullname,
                              style:
                                  AppTextStyle.displayMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              simple.get<AuthViewModel>().authModel!.document,
                              style: AppTextStyle.displayMedium(context)
                                  .copyWith(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: AppSize.padding,
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
          ),
          const Divider(),
          SizedBox(
            height: 6,
            child: widget.isLoading
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
}

class BranchOfficeManagerWidget extends StatefulWidget {
  const BranchOfficeManagerWidget({super.key});

  @override
  State<BranchOfficeManagerWidget> createState() =>
      _BranchOfficeManagerWidgetState();
}

class _BranchOfficeManagerWidgetState extends State<BranchOfficeManagerWidget> {
  late BranchOfficeViewModelImpl branchOfficeViewModel;
  late TextEditingController textEditingController;
  List<BranchOfficeModel> branchOffices = [];

  @override
  void initState() {
    textEditingController = TextEditingController();
    branchOfficeViewModel = simple.get<BranchOfficeViewModelImpl>();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraint) {
      return Obx(
        () {
          final branchOffices =
              simple.get<BranchOfficeViewModelImpl>().branchOfficeList.value;
          return DropBoxWidget<BranchOfficeModel>(
            label: 'Filial',
            width: contraint.maxWidth,
            icon: const Icon(Icons.business),
            dropdownMenuEntries: [
              ...branchOffices
                  .map(
                    (e) => DropdownMenuEntry(value: e, label: e.name),
                  )
                  .toList()
            ],
            onSelected: (e) {
              simple.get<BranchOfficeViewModelImpl>().switchBranchOffice(e);
            },
            controller: textEditingController,
          );
        },
      );
    });
  }
}
