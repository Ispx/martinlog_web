import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/components/banner_component.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/mixins/validators_mixin.dart';
import 'package:martinlog_web/models/branch_office_model.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/dock_type_view_model.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:martinlog_web/widgets/icon_buttom_widget.dart';
import 'package:martinlog_web/widgets/page_widget.dart';
import 'package:martinlog_web/widgets/text_form_field_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BranchOfficeView extends StatefulWidget {
  const BranchOfficeView({super.key});

  @override
  State<BranchOfficeView> createState() => _BranchOfficeViewState();
}

class _BranchOfficeViewState extends State<BranchOfficeView> {
  late final Worker worker;
  final controller = simple.get<BranchOfficeViewModelImpl>();
  late final Worker workerSearch;
  var textSearched = ''.obs;
  @override
  void initState() {
    controller.getAll();
    workerSearch = debounce(textSearched, controller.search);

    worker = ever(controller.appState, (state) {
      if (state is AppStateDone) {
        if (state.result is String) {
          BannerComponent(
            message: state.result,
            backgroundColor: Colors.green,
          );
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    worker.dispose();
    workerSearch.dispose();
    super.dispose();
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
          children: [
            const CreateBranchOfficeWidget(),
            const Gap(5),
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
                          isActicve: controller
                                  .branchOfficeActivated.value.idBranchOffice ==
                              branchOfficeModel.idBranchOffice,
                          onChanged: (isTrue) {
                            if (isTrue) {
                              controller.switchBranchOffice(branchOfficeModel);
                              setState(() {});
                            } else {
                              controller.unlinkfullyBranchOffice();
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
                onRefresh: () async => await controller.getAll(),
                isLoadingItens: controller.appState.value is AppStateLoading,
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

class BranchOfficeWidget extends StatefulWidget {
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
  State<BranchOfficeWidget> createState() => _BranchOfficeWidgetState();
}

class _BranchOfficeWidgetState extends State<BranchOfficeWidget> {
  late final GlobalKey<FormState> formState;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    formState = GlobalKey<FormState>();
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    formState.currentState?.dispose();
    super.dispose();
  }

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
              widget.branchOfficeModel.name,
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
              value: widget.isActicve,
              onChanged: widget.onChanged,
            ),
            SizedBox(
              width: AppSize.padding,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 35.w,
                            height: 100.h,
                            color: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSize.padding * 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5.h,
                                ),
                                GestureDetector(
                                  onTap: GoTo.pop,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 2.w,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  widget.branchOfficeModel.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.displayMedium(context)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.titleColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                SizedBox(
                                  height: AppSize.padding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Form(
                                      key: formState,
                                      child: Expanded(
                                        child: Material(
                                          child: TextFormFieldWidget<
                                              UnderlineInputBorder>(
                                            label: 'Nome da operação',
                                            hint: 'Ex.: Retirada',
                                            validator: (e) {
                                              if (e?.isEmpty ?? true) {
                                                return "Campo não pode estar em branco";
                                              }
                                              if (e?.length == 1) {
                                                return 'Nome inválido';
                                              }
                                              return null;
                                            },
                                            onSaved: (name) async {
                                              await simple
                                                  .get<DockTypeViewModel>()
                                                  .create(
                                                    name: name,
                                                    branchOffice: widget
                                                        .branchOfficeModel,
                                                  );
                                              await simple
                                                  .get<
                                                      BranchOfficeViewModelImpl>()
                                                  .getAll();
                                              GoTo.pop();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: AppSize.padding * 2,
                                    ),
                                    SizedBox(
                                      width: 90,
                                      height: 40,
                                      child: Obx(() {
                                        return ButtomWidget(
                                          onTap: () {
                                            if (formState.currentState
                                                    ?.validate() ??
                                                false) {
                                              formState.currentState?.save();
                                            }
                                          },
                                          isLoading: simple
                                              .get<DockTypeViewModel>()
                                              .appState
                                              .value is AppStateLoading,
                                          radius: 20,
                                          title: 'Criar',
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: AppSize.padding,
                                ),
                                SizedBox(
                                  height: AppSize.padding * 3,
                                ),
                                Text(
                                  "Tipos de opereções:",
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.displayMedium(context)
                                      .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.titleColor,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.padding * 1.5,
                                ),
                                Container(
                                  height: 35.h,
                                  width: double.maxFinite,
                                  color: Colors.white,
                                  child: (widget.branchOfficeModel.dockTypes
                                              ?.isEmpty ??
                                          true)
                                      ? Center(
                                          child: Text(
                                            "Nenhuma operação criada",
                                            style: AppTextStyle.displayMedium(
                                                    context)
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: appTheme.titleColor,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemBuilder: (context, i) {
                                            final dockTypeModel = widget
                                                .branchOfficeModel
                                                .dockTypes![i];
                                            return SizedBox(
                                              width: double.maxFinite,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 2.w,
                                                        height: 2.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: context
                                                              .appTheme
                                                              .secondColor,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Center(
                                                          child: Icon(
                                                            LineIcons.dolly,
                                                            color: Colors.white,
                                                            size: 1.w,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: AppSize.padding,
                                                      ),
                                                      Text(
                                                        dockTypeModel.name,
                                                        style: AppTextStyle
                                                                .displaySmall(
                                                                    context)
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          child: SizedBox
                                                              .shrink()),
                                                    ],
                                                  ),
                                                  const Divider(),
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (c, i) => SizedBox(
                                                height: AppSize.padding,
                                              ),
                                          itemCount: widget.branchOfficeModel
                                                  .dockTypes?.length ??
                                              0),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.settings,
              ),
            )
          ],
        ),
      ),
    );
  }
}
