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

  const PageWidget({
    Key? key,
    required this.itens,
    required this.totalByPage,
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
    totalPages = widget.itens.length ~/ widget.totalByPage +
        (widget.itens.length % widget.totalByPage > 0 ? 1 : 0);
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
                  SizedBox(
                    width: AppSize.padding * 2,
                  ),
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
                      ),
                      IconButton(
                        onPressed: nextPage,
                        icon: Icon(
                          LineIcons.angleRight,
                          color: canNextPage
                              ? Colors.black
                              : context.appTheme.greyColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: AppSize.padding * 2,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        if (widget.onRefresh != null) {
                          widget.onRefresh!();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              );
            }),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSize.padding),
                child: Obx(() {
                  return ListView.builder(
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
