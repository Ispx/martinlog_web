import 'package:flutter/material.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidget extends PreferredSize {
  AppBarWidget(
      {super.key,
      required BuildContext context,
      required String title,
      required Color backgroundColor,
      required Widget content,
      List<Widget>? actions})
      : super(
          preferredSize: Size.fromHeight(13.h),
          child: Container(
            color: backgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSize.padding * 2),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTextStyle.displayLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
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
                                  children: actions,
                                ),
                              )
                            : SizedBox.fromSize(),
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        );
}
