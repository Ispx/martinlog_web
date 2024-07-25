import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/extensions/dock_type_extension.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/extensions/operation_status_extension.dart';
import 'package:martinlog_web/state/app_state.dart';
import 'package:martinlog_web/widgets/buttom_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/dependencie_injection_manager/simple.dart';
import '../../../../enums/operation_status_enum.dart';
import '../../../../models/operation_model.dart';
import '../../../../navigator/go_to.dart';
import '../../../../style/text/app_text_style.dart';
import '../../../../view_models/operation_view_model.dart';
import '../../../../widgets/icon_buttom_widget.dart';

class OperationViewDetailsMobile extends StatefulWidget {
  const OperationViewDetailsMobile({super.key});

  @override
  State<OperationViewDetailsMobile> createState() =>
      _OperationViewDetailsMobileState();
}

class _OperationViewDetailsMobileState
    extends State<OperationViewDetailsMobile> {
  final TextEditingController additionalDataEdittinController =
      TextEditingController();
  var additionalData = ''.obs;

  OperationModel? get operationModel =>
      (ModalRoute.of(context)?.settings.arguments as List<Object>?)?[0]
          as OperationModel;

  OperationViewModel get controller => simple.get<OperationViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      additionalDataEdittinController.text =
          operationModel!.additionalData ?? '';
      additionalData.update((val) {
        if (operationModel!.additionalData != null) {
          additionalData.value = operationModel!.additionalData!;
          setState(() {});
        }
      });
    });
  }

  Future<void> _doSaveDescription() async {
    await controller.getOperation(operationKey: operationModel!.operationKey);
    await controller.updateOperation(
      operationModel: operationModel!,
      progress: controller.operationModel!.progress,
      additionalData: additionalData.value,
    );
  }

  Future<void> _doImportFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return;

    await simple.get<OperationViewModel>().uploadFile(
          operationModel: operationModel!,
          imageBytes: await imageFile.readAsBytes(),
          filename: imageFile.name,
        );
    setState(() {});
  }

  Future<void> _downloadFile() async {
    await controller.downloadFile([operationModel!]);
  }

  Future<void> _doGetImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);
    if (imageFile == null) return;

    await simple.get<OperationViewModel>().uploadFile(
          operationModel: operationModel!,
          imageBytes: await imageFile.readAsBytes(),
          filename: imageFile.name,
        );
    setState(() {});
  }

  Widget _sendImageOptionsButton(
      {required VoidCallback onTap, required String title}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        fixedSize: Size(MediaQuery.of(context).size.width, 48),
      ),
      child: Text(
        title,
        style: AppTextStyle.mobileDisplayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
          color: context.appTheme.titleColor,
        ),
      ),
    );
  }

  void _sendImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final controller = simple.get<OperationViewModel>();
        return Obx(
          () => controller.appState.value is AppStateLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: context.appTheme.primaryColor,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _sendImageOptionsButton(
                        onTap: () async => await _doImportFile(),
                        title: 'Importar Arquivo',
                      ),
                      const Gap(8),
                      const Divider(),
                      const Gap(8),
                      _sendImageOptionsButton(
                        onTap: () async => await _doGetImageFromCamera(),
                        title: 'Tirar Foto',
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        final updatedOperationFunction =
            (ModalRoute.of(context)?.settings.arguments as List<Object>?)?[1]
                as Function;
        await updatedOperationFunction();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Detalhes',
            style: AppTextStyle.displayMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          actions: [
            OperationProgressWidget(operationModel: operationModel!),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Gap(48),
                      ValuesDetailsWidget(
                        title: 'Transportadora:',
                        value: operationModel!.companyModel.fantasyName,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'CNPJ:',
                        value: operationModel!.companyModel.cnpj,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Doca:',
                        value: operationModel!.dockModel!.code,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Tipo:',
                        value: operationModel!.dockModel!.idDockType
                            .getDockType()
                            .description,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Status:',
                        value: operationModel!.idOperationStatus
                            .getOperationStatus()
                            .description,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Data de início:',
                        value: operationModel!
                            .createdAt.toBrazillianHour.ddMMyyyyHHmmss,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Data da finalização:',
                        value: operationModel!.finishedAt?.ddMMyyyyHHmmss ?? '',
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Placa:',
                        value: operationModel!.liscensePlate,
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Descrição:',
                        value: operationModel!.description ?? '',
                      ),
                      const Gap(8),
                      Text.rich(
                        TextSpan(
                          text: 'Anexo: ',
                          style: AppTextStyle.mobileDisplayMedium(context)
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: operationModel!.urlImage != null
                                  ? '${operationModel!.urlImage!.substring(0, 40)}...'
                                  : '',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  if (operationModel!.urlImage != null) {
                                    await launchUrl(
                                      Uri.parse(operationModel!.urlImage!),
                                    );
                                  }
                                },
                              style: AppTextStyle.mobileDisplayMedium(context)
                                  .copyWith(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blueAccent,
                                color: Colors.blueAccent,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Gap(8),
                      ValuesDetailsWidget(
                        title: 'Chave da operação:',
                        value: operationModel!.operationKey,
                      ),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: const Border.fromBorderSide(
                                BorderSide(width: 1, color: Colors.black),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 174,
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: additionalDataEdittinController,
                              enabled: operationModel!.idOperationStatus ==
                                      OperationStatusEnum
                                          .IN_PROGRESS.idOperationStatus &&
                                  controller.appState is! AppStateLoading,
                              maxLength: 255,
                              maxLines: 10,
                              style: AppTextStyle.mobileDisplayMedium(context)
                                  .copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Descrição',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                helperStyle:
                                    AppTextStyle.mobileDisplayMedium(context)
                                        .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (e) {
                                additionalData.value = e;
                              },
                            ),
                          ),
                          const Gap(8),
                          Obx(
                            () => SizedBox(
                              width: 120,
                              height: 40,
                              child: ButtomWidget(
                                elevation: 0,
                                isLoading: controller.appState.value
                                    is AppStateLoading,
                                radius: 10,
                                title: 'Salvar',
                                onTap: () => _doSaveDescription(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(18),
                  IconButtonWidget(
                    icon: const Icon(LineIcons.upload),
                    radius: 5,
                    title: 'Enviar Imagem',
                    onTap: () => _sendImageOptions(context),
                  ),
                  const Gap(18),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButtonWidget(
                            icon: const Icon(LineIcons.download),
                            radius: 5,
                            title: 'Baixar arquivo',
                            onTap: () async => await _downloadFile(),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: IconButtonWidget(
                            icon: const Icon(Icons.close),
                            radius: 5,
                            title: 'Fechar',
                            onTap: () => GoTo.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OperationProgressWidget extends StatefulWidget {
  const OperationProgressWidget({
    Key? key,
    required this.operationModel,
  }) : super(key: key);

  final OperationModel operationModel;

  @override
  State<OperationProgressWidget> createState() =>
      _OperationProgressWidgetState();
}

class _OperationProgressWidgetState extends State<OperationProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> progressAnimation;
  late final Animation<int> textAnimation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });

    progressAnimation =
        Tween<double>(begin: 0.0, end: widget.operationModel.progress / 100)
            .animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );
    textAnimation =
        IntTween(begin: 0, end: widget.operationModel.progress).animate(
      CurvedAnimation(parent: animationController, curve: Curves.decelerate),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      height: 32,
      width: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "${textAnimation.value}%",
            style: AppTextStyle.mobileDisplaySmall(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progressAnimation.value,
              strokeWidth: 4,
              color: widget.operationModel.idOperationStatus ==
                      OperationStatusEnum.CANCELED.idOperationStatus
                  ? context.appTheme.greyColor
                  : context.appTheme.primaryColor,
              backgroundColor: Colors.grey.shade200,
              semanticsValue: textAnimation.value.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class ValuesDetailsWidget extends StatelessWidget {
  final String title;
  final String value;
  const ValuesDetailsWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "$title ",
        style: AppTextStyle.mobileDisplayMedium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: AppTextStyle.mobileDisplayMedium(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
