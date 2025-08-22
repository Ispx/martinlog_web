import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IUploadFileOperationRepository {
  Future<String> call({
    required String operationKey,
    required String filename,
    required Uint8List imageBytes,
  });
}

final class UploadFileOperationRepository
    implements IUploadFileOperationRepository {
  final IHttp http;
  final String urlBase;
  UploadFileOperationRepository({
    required this.http,
    required this.urlBase,
  });
  @override
  Future<String> call({
    required String operationKey,
    required String filename,
    required Uint8List imageBytes,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(imageBytes, filename: filename),
      });
      final url = urlBase +
          Endpoints.operationUploadFile
              .replaceAll("<operationKey>", operationKey);

      final response = await http.request<Response>(
        url: url,
        method: HttpMethod.POST,
        body: formData,
      );
      return response.data['urlImage'];
    } catch (e) {
      throw "Ocorreu um erro ao fazer upload do arquivo";
    }
  }
}
