import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/models/company_model.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BindBranchOfficeView extends StatefulWidget {
  const BindBranchOfficeView({super.key});

  @override
  State<BindBranchOfficeView> createState() => _BindBranchOfficeViewState();
}

class _BindBranchOfficeViewState extends State<BindBranchOfficeView> {
  final controller = simple.get<BranchOfficeViewModelImpl>();
  late final Worker workerSearch;
  var textSearched = ''.obs;
  var branchOfficesBindList = <BranchOfficeModel>[].obs;
  CompanyModel get companyModel => controller.companyModel!;
  @override
  void initState() {
    workerSearch = debounce(textSearched, controller.search);
    branchOfficesBindList.value = controller.companyModel!.branchOffices;
    super.initState();
  }

  @override
  void dispose() {
    workerSearch.dispose();
    super.dispose();
  }

  bool isActive(BranchOfficeModel branch) {
    for (var branchOffice in branchOfficesBindList) {
      if (branchOffice.idBranchOffice == branch.idBranchOffice) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(
        vertical: AppSize.padding,
        horizontal: AppSize.padding * 2,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(5),
            Text(
              companyModel.socialRason.toUpperCase(),
              style: AppTextStyle.displayLarge(context).copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(8),
            Text(
              "CNPJ: ${companyModel.cnpj.toUpperCase()}",
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const Gap(30),
            Row(
              children: [
                SizedBox(
                  width: AppSize.padding,
                ),
                Expanded(
                  child: TextFormFieldWidget<OutlineInputBorder>(
                    label: 'Pesquisar',
                    hint: 'Pesquise por nome, documento ou transportadora',
                    onChange: (e) => textSearched.value = e,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
              ],
            ),
            const Gap(10),
            Obx(() {
              return PageWidget(
                key: ValueKey(DateTime.now()),
                itens: (controller.branchsSearched.isEmpty
                        ? controller.branchOfficeList.value
                        : controller.branchsSearched.value)
                    .map(
                      (branchOfficeModel) => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSize.padding / 2,
                        ),
                        child: BranchOfficeWidget(
                          branchOfficeModel: branchOfficeModel,
                          isActicve: isActive(branchOfficeModel),
                          onChanged: (isTrue) {
                            if (isTrue) {
                              branchOfficesBindList.add(branchOfficeModel);
                              controller.linkCompany(
                                  companyModel, branchOfficeModel);
                            } else {
                              branchOfficesBindList.remove(branchOfficeModel);
                              controller.unLinkCompany(
                                  companyModel, branchOfficeModel);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    )
                    .toList(),
                onRefresh: () async => await controller.getAll(),
                onDownload: null,
                totalByPage: 10,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CreateBranchOfficeWidget extends StatefulWidget {
  const CreateBranchOfficeWidget({super.key});

  @override
  State<CreateBranchOfficeWidget> createState() =>
      _CreateBranchOfficeWidgetState();
}

class _CreateBranchOfficeWidgetState extends State<CreateBranchOfficeWidget>
    with ValidatorsMixin {
  var isLoading = false;
  var isOpen = false;
  late TextEditingController nameEditingController;

  late final GlobalKey<FormState> formState;
  final controller = simple.get<BranchOfficeViewModelImpl>();
  @override
  void initState() {
    formState = GlobalKey<FormState>();
    nameEditingController = TextEditingController();
    super.initState();
  }

  void open() {
    isOpen = true;
    setState(() {});
  }

  void close() {
    isOpen = false;
    setState(() {});
  }

  Future<void> create() async {
    if (formState.currentState?.validate() ?? false) {
      isLoading = true;
      setState(() {});
      await controller.create(
        nameEditingController.text,
      );
      isLoading = false;
      setState(() {});
      nameEditingController.clear();
    }
  }

  @override
  void dispose() {
    formState.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isOpen
        ? Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 15.w,
              child: IconButtonWidget(
                onTap: open,
                title: 'Nova Filial',
                icon: const Icon(Icons.business),
              ),
            ),
          )
        : LayoutBuilder(builder: (context, contraint) {
            return Container(
              width: contraint.maxWidth,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: buildSelectable(
                      context: context,
                      title: "Nome da filial...",
                      child: Form(
                        key: formState,
                        child: TextFormFieldWidget<OutlineInputBorder>(
                          controller: nameEditingController,
                          enable: controller.appState.value is! AppStateLoading,
                          validator: isNotEmpity,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSize.padding * 2,
                  ),
                  Flexible(
                    child: Center(
                      child: buildSelectable(
                        context: context,
                        title: "",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: IconButtonWidget(
                                onTap: close,
                                title: 'Fechar',
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.padding * 2,
                            ),
                            Expanded(
                              child: IconButtonWidget(
                                onTap: () => isLoading ? null : create(),
                                title: 'Criar',
                                icon: const Icon(LineIcons.check),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
  }

  Widget buildSelectable(
      {required BuildContext context,
      required String title,
      required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.displayMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: AppSize.padding,
        ),
        child,
      ],
    );
  }
}

class BranchOfficeWidget extends StatelessWidget {
  final BranchOfficeModel branchOfficeModel;
  final bool isActicve;
  final Function(bool) onChanged;
  const BranchOfficeWidget({
    super.key,
    required this.branchOfficeModel,
    required this.isActicve,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSize.padding * 1.5,
          horizontal: AppSize.padding,
        ),
        child: Row(
          children: [
            const Icon(Icons.business),
            SizedBox(
              width: AppSize.padding,
            ),
            Text(
              branchOfficeModel.name,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.displayMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: appTheme.titleColor,
              ),
            ),
            const Expanded(
              child: SizedBox.shrink(),
            ),
            Switch(
              value: isActicve,
              onChanged: onChanged,
            )
          ],
        ),
      ),
    );
  }
}
