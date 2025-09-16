import 'package:martinlog_web/core/config/env_confg.dart';
import 'package:martinlog_web/core/dependencie_injection_manager/simple.dart';
import 'package:martinlog_web/enums/profile_type_enum.dart';
import 'package:martinlog_web/extensions/int_extension.dart';
import 'package:martinlog_web/view_models/auth_view_model.dart';
import 'package:web_socket_client/web_socket_client.dart';

class WsService {
  static final WsService _i = WsService._();
  WsService._();
  factory WsService() => _i;

  WebSocket? socket;

  Future<void> connect({required String channel}) async {
    final url = "${EnvConfig.wsBase}/ws/$channel";
    final uri = Uri.parse(url);
    if (simple.get<AuthViewModel>().authModel!.idProfile.getProfile() ==
        ProfileTypeEnum.MASTER) {
      socket = WebSocket(uri);
      socket?.send('connected');
    }
  }

  Future<void> disconect() async {
    if (socket != null) {
      socket?.close(1, "normal");
    }
  }
}
