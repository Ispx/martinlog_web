import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class PageWidget extends StatefulWidget {
  final List<Widget> itens;
  final int totalByPage;
  final VoidCallback? onRefresh;
  final VoidCallback? onDownload;
  final VoidCallback? onLoadMoreItens;
  final bool? isEnableLoadMoreItens;

  final Function(int? index)? onPageChanged;
  final bool isLoadingItens;
  const PageWidget({
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
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  var currentIndexPage = 0.obs;
  late final Worker worker;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: 80.h,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.padding / 2,
        ),
        child: Column(
          children: [
            Obx(() {
              final bool canPreviousPage = currentIndexPage.value > 0;
              final bool canNextPage = widget.isEnableLoadMoreItens ?? false
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
                        onPressed: !canNextPage ? null : () => nextPage(),
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
                      shape: WidgetStateProperty.resolveWith(
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
                            shape: WidgetStateProperty.resolveWith(
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
            SizedBox(
              height: AppSize.padding * 2,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSize.padding,
                  horizontal: AppSize.padding,
                ),
                child: widget.isLoadingItens
                    ? ListView.builder(
                        itemCount: 5,
                        physics: !kIsWeb
                            ? const NeverScrollableScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Shimmer.fromColors(
                            enabled: false,
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.white,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              height: 90,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: !kIsWeb
                            ? const NeverScrollableScrollPhysics()
                            : BouncingScrollPhysics(),
                        itemCount: sublistItens.length,
                        itemBuilder: (context, index) => sublistItens[index],
                      ),
              ),
            ),
            SizedBox(height:5.h),
          ],
        ),
      ),
    );
  }
}
