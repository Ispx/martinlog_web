import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

class PageWidgetMobile extends StatefulWidget {
  final List<Widget> itens;
  final int totalByPage;
  final VoidCallback? onRefresh;
  final VoidCallback? onDownload;
  final VoidCallback? onLoadMoreItens;
  final bool isLoadingItens;
  final bool? isEnableLoadMoreItens;

  final Function(int? index)? onPageChanged;
  const PageWidgetMobile({
    Key? key,
    required this.itens,
    required this.totalByPage,
    this.onDownload,
    this.onRefresh,
    this.onLoadMoreItens,
    this.isLoadingItens = false,
    this.isEnableLoadMoreItens,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<PageWidgetMobile> createState() => _PageWidgetMobileState();
}

class _PageWidgetMobileState extends State<PageWidgetMobile> {
  late final Worker worker;

  var currentIndexPage = 0.obs;
  int get totalPages =>
      widget.itens.length ~/ widget.totalByPage +
      (widget.itens.length % widget.totalByPage > 0 ? 1 : 0);
  @override
  void initState() {
    worker = ever(currentIndexPage, (index) {
      widget.onPageChanged?.call(index);
    });
    super.initState();
  }

  List<Widget> get sublistItens => Utils.getWidgetsByPage(
        totalByPage: widget.totalByPage,
        currentIndexPage: currentIndexPage.value,
        widgets: widget.itens,
      );
  void nextPage() {
    currentIndexPage.value++;
    setState(() {});
  }

  void previousPage() {
    if (currentIndexPage.value == 0) return;
    currentIndexPage.value--;
    setState(() {});
  }

  @override
  void dispose() {
    worker.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: null,
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.padding / 2,
      ),
      child: Column(
        children: [
          Obx(() {
            final bool canPreviousPage = currentIndexPage.value > 0;
            final bool canNextPage = widget.onLoadMoreItens != null
                ? true
                : currentIndexPage.value < totalPages - 1;

            return Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Row(
                  children: [
                    IconButton(
                      onPressed: previousPage,
                      icon: Icon(
                        LineIcons.angleLeft,
                        color: canPreviousPage
                            ? Colors.black
                            : context.appTheme.greyColor,
                      ),
                      tooltip: "Página anterior",
                    ),
                    Text("${currentIndexPage.value + 1}"),
                    IconButton(
                      onPressed: nextPage,
                      icon: Icon(
                        LineIcons.angleRight,
                        color: canNextPage
                            ? Colors.black
                            : context.appTheme.greyColor,
                      ),
                      tooltip: "Próxima página",
                    ),
                  ],
                ),
                SizedBox(
                  width: AppSize.padding * 2,
                ),
                IconButton(
                  onPressed: () {
                    if (widget.onRefresh != null) {
                      widget.onRefresh!();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: "Atualizar dados",
                  style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSize.padding * 2,
                ),
                widget.onDownload != null
                    ? IconButton(
                        onPressed: widget.onDownload,
                        tooltip: "Baixar arquivo",
                        icon: const Icon(
                          LineIcons.download,
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          }),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSize.padding),
            child: widget.isLoadingItens
                ? SizedBox(
                    height: 800,
                    child: ListView.builder(
                        itemCount: 10,
                        physics: !kIsWeb
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.white,
                                child: const OperatioSkeleton(),
                              ),
                            )),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        !kIsWeb ? const NeverScrollableScrollPhysics() : null,
                    itemCount: sublistItens.length,
                    itemBuilder: (context, index) => sublistItens[index],
                  ),
          ),
        ],
      ),
    );
  }
}

class OperatioSkeleton extends StatelessWidget {
  const OperatioSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? SizedBox(
            width: Get.width,
            child: Card(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.padding * 1.5,
                  horizontal: AppSize.padding,
                ),
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 360,
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          );
  }
}
