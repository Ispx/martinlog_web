import 'package:flutter/material.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidget extends PreferredSize {
  AppBarWidget(
      {super.key,
      required BuildContext context,
      required Widget content,
      List<Widget>? actions})
      : super(
          preferredSize: Size.fromHeight(20.h),
          child: Card(
            color: context.appTheme.primaryColor,
            child: Row(
              children: [
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
        );
}
