import 'package:flutter/material.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/extensions/build_context_extension.dart';
import 'package:martinlog_web/extensions/date_time_extension.dart';
import 'package:martinlog_web/models/notification_model.dart';
import 'package:martinlog_web/models/operation_model.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/notification_view_model.dart';
import 'package:martinlog_web/view_models/operation_view_model.dart';
import 'package:martinlog_web/views/web/operation_view.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notificationModel;
  const NotificationWidget({
    super.key,
    required this.notificationModel,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late final NotificationViewModel notificationViewModel;
  late bool viewed;
  @override
  void initState() {
    notificationViewModel = simple.get<NotificationViewModel>();
    viewed = widget.notificationModel.viewed;
    super.initState();
  }

  Future<void> onViewed() async {
    String goTo = widget.notificationModel.payload['goTo'] ?? '';

    if (!widget.notificationModel.viewed) {
      notificationViewModel.updateViewed(widget.notificationModel);
      viewed = true;
      setState(() {});
    }

    if (goTo.isNotEmpty) {
      String operationKey = goTo.split("/").last;
      OperationModel? operationModel = await simple
          .get<OperationViewModel>()
          .fetchOperationByKey(operationKey: operationKey);

      if (operationModel != null) {
        showDialogDetailsOperation(context, operationModel);
      }
    }
  }

  void onTap() {
    onViewed();
  }

  Color get backgroundColor =>
      viewed ? Colors.white : context.appTheme.secondColor;

  Color get textColor => viewed ? Colors.black : Colors.white;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSize.padding,
          horizontal: AppSize.padding / 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: AppSize.padding / 2,
                ),
                Icon(
                  Icons.notifications,
                  color: viewed ? Colors.black : Colors.white,
                ),
                SizedBox(
                  width: AppSize.padding,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notificationModel.createdAt!.ddMMyyyyHHmmss,
                      style: AppTextStyle.displaySmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.padding / 2,
                    ),
                    Text(
                      widget.notificationModel.title,
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.padding / 2,
                    ),
                    const Divider(),
                    SizedBox(
                      height: AppSize.padding / 2,
                    ),
                    Text(
                      widget.notificationModel.body,
                      style: AppTextStyle.displayMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
