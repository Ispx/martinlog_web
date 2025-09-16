import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:martinlog_web/core/config/firebase_push_config.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/notification_topic_enum.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/profile_type_extension.dart';
import 'package:martinlog_web/style/size/app_size.dart';
import 'package:martinlog_web/style/text/app_text_style.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:martinlog_web/view_models/branch_office_view_model.dart';
import 'package:martinlog_web/view_models/company_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.padding * 2,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationSettingsWidget(),
            Divider(),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  final _storage = const FlutterSecureStorage();

  String topicName(NotificationTopicsEnum topic) {
    int idBranchOffice = simple
        .get<BranchOfficeViewModelImpl>()
        .branchOfficeActivated
        .value
        .idBranchOffice;
    int idCompany = simple.get<CompanyViewModel>().companyModel!.idCompany;
    return simple.get<AuthViewModel>().authModel!.idProfile ==
            ProfileTypeEnum.MASTER.idProfileType
        ? 'profile_${simple.get<AuthViewModel>().authModel!.idProfile}_idBranchOffice_${idBranchOffice}_topic_${topic.description}'
        : 'profile_${simple.get<AuthViewModel>().authModel!.idProfile}_idBranchOffice_${idBranchOffice}_idCompany_${idCompany}_topic_${topic.description}';
  }

  Future<void> handlerSubscriberTopic(bool isSubscriber, String topic) async {
    await _saveValueInLocalStorage(topic, isSubscriber);
    if (isSubscriber) {
      await FirebasePushConfig.subscriberTopic(topic);
    } else {
      await FirebasePushConfig.unsubscriberTopic(topic);
    }
  }

  Future<bool> _getValueInLocalStorage(String key) async {
    return (await _storage.read(key: key)) == 'true';
  }

  Future<void> _saveValueInLocalStorage(String key, bool value) async {
    await _storage.write(key: key, value: value ? 'true' : 'false');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AppSize.padding * 3,
        ),
        Text(
          "Notificações",
          style: AppTextStyle.mobileDisplayLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: AppSize.padding * 4,
        ),
        Text(
          "Defina os tipos de eventos das operações que você deseja ser notificado.",
          style: AppTextStyle.mobileDisplayMedium(context),
        ),
        SizedBox(
          height: AppSize.padding * 4,
        ),
        TopicSubscriberOperationNotificationWidget(
          key: const ObjectKey(NotificationTopicsEnum.OPERATION_CREATED),
          onSubscriber: handlerSubscriberTopic,
          title: 'Operação criada',
          value: _getValueInLocalStorage(
              topicName(NotificationTopicsEnum.OPERATION_CREATED)),
          topic: topicName(NotificationTopicsEnum.OPERATION_CREATED),
        ),
        SizedBox(
          height: AppSize.padding * 2,
        ),
        TopicSubscriberOperationNotificationWidget(
          key: const ObjectKey(NotificationTopicsEnum.OPERATION_CANCELED),
          onSubscriber: handlerSubscriberTopic,
          title: 'Operação cancelada',
          value: _getValueInLocalStorage(
              topicName(NotificationTopicsEnum.OPERATION_CANCELED)),
          topic: topicName(NotificationTopicsEnum.OPERATION_CANCELED),
        ),
        SizedBox(
          height: AppSize.padding * 2,
        ),
        TopicSubscriberOperationNotificationWidget(
          key: const ObjectKey(NotificationTopicsEnum.OPERATION_UPDATED),
          onSubscriber: handlerSubscriberTopic,
          title: 'Qualquer alteração.',
          value: _getValueInLocalStorage(
              topicName(NotificationTopicsEnum.OPERATION_UPDATED)),
          topic: topicName(NotificationTopicsEnum.OPERATION_UPDATED),
        ),
        SizedBox(
          height: AppSize.padding * 2,
        ),
        TopicSubscriberOperationNotificationWidget(
          key: const ObjectKey(NotificationTopicsEnum.OPERATION_FINISHED),
          onSubscriber: handlerSubscriberTopic,
          title: 'Operação finalizada',
          value: _getValueInLocalStorage(
              topicName(NotificationTopicsEnum.OPERATION_FINISHED)),
          topic: topicName(NotificationTopicsEnum.OPERATION_FINISHED),
        ),
        SizedBox(
          height: AppSize.padding * 4,
        ),
      ],
    );
  }
}

class TopicSubscriberOperationNotificationWidget extends StatefulWidget {
  final String title;
  final Function(bool isSubscriber, String topic) onSubscriber;
  final String topic;
  final Future<bool> value;
  const TopicSubscriberOperationNotificationWidget({
    super.key,
    required this.onSubscriber,
    required this.title,
    required this.topic,
    required this.value,
  });

  @override
  State<TopicSubscriberOperationNotificationWidget> createState() =>
      _TopicSubscriberOperationNotificationWidgetState();
}

class _TopicSubscriberOperationNotificationWidgetState
    extends State<TopicSubscriberOperationNotificationWidget> {
  bool value = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((e) async {
      value = await widget.value;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: AppTextStyle.mobileDisplayMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: (e) {
            value = e;

            widget.onSubscriber.call(e, widget.topic);
            setState(() {});
          },
        )
      ],
    );
  }
}
