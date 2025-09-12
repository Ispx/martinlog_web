import 'package:flutter/material.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/notification_view_model.dart';
import 'package:martinlog_web/widgets/notification_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final notificationViewModel = simple.get<NotificationViewModel>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          child: Container(
            width: 25.w,
            height: 100.h,
            color: notificationViewModel.notifications.isEmpty
                ? Colors.white
                : Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.padding,
            ),
            child: Material(
              color: notificationViewModel.notifications.isEmpty
                  ? Colors.white
                  : Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Visibility(
                      visible: notificationViewModel.notifications.isEmpty,
                      child: Text(
                        "Nenhuma notificação registrada",
                        style: AppTextStyle.displayMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...notificationViewModel.notifications.map(
                      (notificationModel) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSize.padding,
                          ),
                          child: NotificationWidget(
                            key: ValueKey(notificationModel.idNotification),
                            notificationModel: notificationModel,
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
