import 'package:flutter/material.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/utils/utils.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppBarWidgetMobile extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Widget content;
  final List<Widget>? actions;
  final Widget? prefix;
  final bool isLoading;

  const AppBarWidgetMobile({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.content,
    this.isLoading = false,
    this.actions,
     this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.padding * 2),
            child: Row(
              children: [
                if (prefix != null) prefix!,
                Text(
                  title,
                  style: AppTextStyle.displayLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: context.appTheme.secondColor,
                        child: Text(
                          Utils.getInitials(
                            simple.get<AuthViewModel>().authModel!.fullname,
                          ),
                          style: AppTextStyle.displayMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: AppSize.padding,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            simple.get<AuthViewModel>().authModel!.fullname,
                            style: AppTextStyle.displayMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            simple.get<AuthViewModel>().authModel!.document,
                            style: AppTextStyle.displayMedium(context).copyWith(),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
                IconButton(
                  onPressed: () async => await simple.get<AuthViewModel>().loggout(),
                  icon: const Icon(
                    Icons.exit_to_app,
                  ),
                )
              ],
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

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
