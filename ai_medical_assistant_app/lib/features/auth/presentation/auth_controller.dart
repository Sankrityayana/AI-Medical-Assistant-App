import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

final authStatusProvider = StateProvider<AuthStatus>((ref) => AuthStatus.unknown);

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  Future<void> checkSession() async {
    final token = await _ref.read(secureStorageProvider).getAccessToken();
    _ref.read(authStatusProvider.notifier).state =
        token != null && token.isNotEmpty ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<String?> login({required String username, required String password}) async {
    try {
      final result = await _ref.read(authRepositoryProvider).login(username: username, password: password);
      await _ref.read(secureStorageProvider).saveTokens(
            access: result['access'] as String,
            refresh: result['refresh'] as String,
          );
      _ref.read(authStatusProvider.notifier).state = AuthStatus.authenticated;
      return null;
    } catch (e) {
      return 'Login failed. Please check credentials.';
    }
  }

  Future<String?> register({required String username, required String email, required String password}) async {
    try {
      await _ref.read(authRepositoryProvider).register(username: username, email: email, password: password);
      return await login(username: username, password: password);
    } catch (e) {
      return 'Registration failed. Try a different username.';
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).clearTokens();
    _ref.read(authStatusProvider.notifier).state = AuthStatus.unauthenticated;
  }
}
