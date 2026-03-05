import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
        'email': email,
        'password': password,
      },
    );

    final token = res.data?['accessToken'];
    if (token is! String || token.isEmpty) {
      throw Exception('Invalid login response');
    }
    return token;
  }

  Future<String> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    final token = res.data?['accessToken'];
    if (token is! String || token.isEmpty) {
      throw Exception('Invalid register response');
    }
    return token;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/auth/me');
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/users/me');
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? phone,
    String? whatsapp,
    String? shippingAddress,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        if (phone != null) 'phone': phone,
        if (whatsapp != null) 'whatsapp': whatsapp,
        if (shippingAddress != null) 'shippingAddress': shippingAddress,
      },
    );
    return res.data ?? <String, dynamic>{};
  }
}
