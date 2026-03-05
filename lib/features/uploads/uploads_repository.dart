import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

final uploadsRepositoryProvider = Provider<UploadsRepository>((ref) {
  return UploadsRepository(ref.read(dioProvider));
});

class UploadsRepository {
  UploadsRepository(this._dio);

  final Dio _dio;

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/uploads/images',
        data: form,
      );

      final url = res.data?['publicUrl'];
      if (url is! String || url.isEmpty) {
        throw Exception('Invalid upload response');
      }
      return url;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception('Upload failed ($status): $data');
    }
  }

  Future<String> uploadReceipt({
    required Uint8List bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/uploads/receipts',
        data: form,
      );

      final url = res.data?['publicUrl'];
      if (url is! String || url.isEmpty) {
        throw Exception('Invalid upload response');
      }
      return url;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception('Upload failed ($status): $data');
    }
  }
}
