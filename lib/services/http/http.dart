import 'package:http/http.dart' as http;

enum HttpMethod { GET, POST, PUT }

abstract interface class IHttp {
  Future<T> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
  });
}

class Http implements IHttp {
  @override
  Future<T> request<T>(
      {required String url,
      required HttpMethod method,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      Map<String, dynamic>? params}) async {
    final Uri uri = Uri(scheme: url);
    return switch (method) {
      HttpMethod.GET => await http.get(uri, headers: headers),
      HttpMethod.POST => await http.post(uri, headers: headers, body: body),
      HttpMethod.PUT => await http.post(uri, headers: headers, body: body)
    } as T;
  }
}
