import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'jwt_utils.dart';
import 'token_storage.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({
    required this.accessToken,
    required this.isLoading,
    required this.role,
    required this.tenantId,
  });

  final String? accessToken;
  final bool isLoading;
  final String? role;
  final String? tenantId;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  bool get isAdmin => role == 'admin';

  AuthState copyWith({
    String? accessToken,
    bool? isLoading,
    String? role,
    String? tenantId,
  }) {
    return AuthState(
      accessToken: accessToken,
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  static const empty = AuthState(
    accessToken: null,
    isLoading: false,
    role: null,
    tenantId: null,
  );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    return const AuthState(
      accessToken: null,
      isLoading: true,
      role: null,
      tenantId: null,
    );
  }

  Future<void> _load() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    if (token != null && token.isNotEmpty) {
      final payload = decodeJwtPayload(token);
      state = state.copyWith(
        accessToken: token,
        isLoading: false,
        role: payload?['role'] as String?,
        tenantId: payload?['tenantId'] as String?,
      );
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(tokenStorageProvider).writeAccessToken(token);
      final payload = decodeJwtPayload(token);
      state = AuthState(
        accessToken: token,
        isLoading: false,
        role: payload?['role'] as String?,
        tenantId: payload?['tenantId'] as String?,
      );
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await ref
          .read(authRepositoryProvider)
          .register(email: email, password: password, role: role);
      await ref.read(tokenStorageProvider).writeAccessToken(token);
      final payload = decodeJwtPayload(token);
      state = AuthState(
        accessToken: token,
        isLoading: false,
        role: payload?['role'] as String?,
        tenantId: payload?['tenantId'] as String?,
      );
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearAccessToken();
    state = AuthState.empty;
  }
}
