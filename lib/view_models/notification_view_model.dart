import 'package:get/get.dart';
import 'package:martinlog_web/models/notification_model.dart';
import 'package:martinlog_web/repositories/get_notification_repository.dart';
import 'package:martinlog_web/repositories/update_viewed_notification_repository.dart';
import 'package:martinlog_web/state/app_state.dart';

abstract interface class INotificationViewModel {
  Future<void> updateViewed(NotificationModel notificationModel);
  Future<void> getAll();
  Future<void> add(NotificationModel notificationModel);
}

class NotificationViewModel extends GetxController
    implements INotificationViewModel {
  var appState = AppState().obs;
  final IGetNotificationsRepository getNotificationsRepository;
  final IUpdateViewedNotificationRepository updateViewedNotificationRepository;
  var notifications = <NotificationModel>[].obs;
  int get totalNotViewed => notifications.value.where((e) => !e.viewed).length;
  void changeState(AppState appState) {
    this.appState.value = appState;
  }

  NotificationViewModel({
    required this.getNotificationsRepository,
    required this.updateViewedNotificationRepository,
  });
  @override
  Future<void> getAll() async {
    try {
      changeState(AppStateLoading());
      notifications.value = await getNotificationsRepository();
      changeState(AppStateDone());
      _scheduleNexTask(getAll);
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  void _scheduleNexTask(Function task) {
    Future.delayed(1.minutes, () => task.call());
  }

  @override
  Future<void> updateViewed(NotificationModel notificationModel) async {
    try {
      changeState(AppStateLoading());
      notifications.value = List.from(notifications)
        ..replaceRange(notifications.indexOf(notificationModel),
            notifications.indexOf(notificationModel) + 1, [
          notificationModel.copyWith(
            viewed: true,
          )
        ]);
      await updateViewedNotificationRepository(
          notificationModel.idNotification!);

      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }

  @override
  Future<void> add(NotificationModel notificationModel) async {
    try {
      changeState(AppStateLoading());
      notifications.add(notificationModel);
      changeState(AppStateDone());
    } catch (e) {
      changeState(AppStateError(e.toString()));
    }
  }
}
