import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerState =
    GlobalKey<ScaffoldMessengerState>();

class BannerComponent {
  BannerComponent({
    required String message,
    List<Widget>? actions,
    Color? backgroundColor,
    Duration? duration,
  }) {
    scaffoldMessengerState.currentState?.showMaterialBanner(MaterialBanner(
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: backgroundColor,
      actions: actions ?? [const SizedBox.shrink()],
      onVisible: () {
        Future.delayed(duration ?? 2.seconds, () {
          scaffoldMessengerState.currentState?.clearMaterialBanners();
        });
      },
    ));
  }
}
