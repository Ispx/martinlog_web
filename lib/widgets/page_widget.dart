import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/utils/utils.dart';

class PageWidget extends StatefulWidget {
  final List<Widget> itens;
  final int totalByPage;
  final VoidCallback? onRefresh;
  final VoidCallback? onDownload;
  const PageWidget({
    Key? key,
    required this.itens,
    required this.totalByPage,
    this.onDownload,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  var currentIndexPage = 0.obs;
  late final int totalPages;
  var sublistItens = <Widget>[].obs;
  @override
  void initState() {
    totalPages = widget.itens.length ~/ widget.totalByPage + (widget.itens.length % widget.totalByPage > 0 ? 1 : 0);
    sublistItens.value = Utils.getWidgetsByPage(
      totalByPage: widget.totalByPage,
      currentIndexPage: currentIndexPage.value,
      widgets: widget.itens,
    );
    super.initState();
  }

  void nextPage() {
    if (currentIndexPage.value == totalPages - 1) return;
    currentIndexPage.value++;
    sublistItens.value = Utils.getWidgetsByPage(
      totalByPage: widget.totalByPage,
      currentIndexPage: currentIndexPage.value,
      widgets: widget.itens,
    );
  }

  void previousPage() {
    if (currentIndexPage.value == 0) return;
    currentIndexPage.value--;
    sublistItens.value = Utils.getWidgetsByPage(
      totalByPage: widget.totalByPage,
      currentIndexPage: currentIndexPage.value,
      widgets: widget.itens,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      height: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.padding / 2,
        ),
        child: Column(
          children: [
            Obx(() {
              final bool canPreviousPage = currentIndexPage.value > 0;
              final bool canNextPage = currentIndexPage.value < totalPages - 1;
              return Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  Row(
                    children: [
                      IconButton(
                        onPressed: previousPage,
                        icon: Icon(
                          LineIcons.angleLeft,
                          color: canPreviousPage ? Colors.black : context.appTheme.greyColor,
                        ),
                        tooltip: "Página anterior",
                      ),
                      Text("${currentIndexPage.value + 1}"),
                      IconButton(
                        onPressed: nextPage,
                        icon: Icon(
                          LineIcons.angleRight,
                          color: canNextPage ? Colors.black : context.appTheme.greyColor,
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSize.padding),
                child: Obx(() {
                  return ListView.builder(
                    physics: !kIsWeb ? const NeverScrollableScrollPhysics() : null,
                    itemCount: sublistItens.length,
                    itemBuilder: (context, index) => sublistItens[index],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
