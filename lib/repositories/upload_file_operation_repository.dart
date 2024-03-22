import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:martinlog_web/core/consts/endpoints.dart';
import 'package:martinlog_web/services/http/http.dart';

abstract interface class IUploadFileOperationRepository {
  Future<String> call({
    required String operationKey,
    required List<int> fileBytes,
    required String filename,
    required File file,
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
    required List<int> fileBytes,
    required String filename,
    required File file,
  }) async {
    try {
      FormData body = FormData.fromMap({
        "file": kIsWeb
            ? MultipartFile.fromBytes(fileBytes, filename: filename)
            : MultipartFile.fromFile(
                file.path,
                filename: filename,
              ),
      });
      final url = urlBase +
          Endpoints.operationUploadFile
              .replaceAll("<operationKey>", operationKey);

      final response = await http.request<Response>(
        url: url,
        method: HttpMethod.POST,
        body: body,
        headers: {
          "Content-Type": "multipart/form-data",
        },
      );
      return response.data['urlImage'];
    } catch (e) {
      throw "Ocorreu um erro ao fazer upload do arquivo";
    }
  }
}
