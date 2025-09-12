import 'package:flutter/material.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/navigator/go_to.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/view_models/notification_view_model.dart';
import 'package:martinlog_web/widgets/notification_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          child: Container(
            width: 25.w,
            height: 100.h,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.padding,
            ),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    ...simple.get<NotificationViewModel>().notifications.map(
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
