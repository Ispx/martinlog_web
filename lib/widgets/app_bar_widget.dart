import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      height: 13.h,
      color: backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.padding * 2),
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyle.displayLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: content,
                  ),
                  actions != null
                      ? Flexible(
                          flex: 2,
                          child: Row(
                            children: actions ?? [],
                          ),
                        )
                      : SizedBox.fromSize(),
                ],
              ),
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
}
