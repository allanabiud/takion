import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/core/network/supabase_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthFlowException implements Exception {
  const AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

@riverpod
class AuthState extends _$AuthState {
  String _friendlyAuthMessage(Object error, {required bool isSignUp}) {
    if (error is AuthFlowException) {
      return error.message;
    }

    if (error is AuthException) {
      final code = error.code?.toLowerCase().trim();
      final message = error.message.toLowerCase().trim();

      if (code == 'invalid_credentials' || message.contains('invalid login credentials')) {
        return 'Incorrect email or password. Please try again.';
      }

      if (code == 'email_not_confirmed' || message.contains('email not confirmed')) {
        return 'Please verify your email before logging in.';
      }

      if (code == 'user_already_exists' ||
          code == 'email_exists' ||
          message.contains('user already registered')) {
        return 'An account with this email already exists. Try logging in instead.';
      }

      if (code == 'invalid_email' || message.contains('invalid email')) {
        return 'Please enter a valid email address.';
      }

      if (code == 'weak_password' || message.contains('password should be at least')) {
        return 'Password is too weak. Use at least 6 characters.';
      }

      if (code == 'signup_disabled' || message.contains('signups not allowed')) {
        return 'Account creation is currently disabled. Please try again later.';
      }

      if (code == 'over_request_rate_limit' ||
          code == 'too_many_requests' ||
          message.contains('too many requests')) {
        return 'Too many attempts. Please wait a moment and try again.';
      }

      return error.message;
    }

    final lower = error.toString().toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection closed before full header was received')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    return isSignUp
        ? 'Could not create account. Please try again.'
        : 'Could not log in. Please try again.';
  }

  @override
  Future<AuthStatus> build() async {
    final client = ref.watch(supabaseClientProvider);
    final hasSession = client.auth.currentSession != null;
    return hasSession
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final client = ref.read(supabaseClientProvider);
    final profileService = ref.read(supabaseProfileServiceProvider);

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;
      if (user == null) {
        state = AsyncValue.error('Unable to sign in.', StackTrace.current);
        return;
      }

      await profileService.ensureProfile(
        user: user,
        displayName: user.userMetadata?['display_name'] as String?,
      );

      state = const AsyncValue.data(AuthStatus.authenticated);
    } catch (e, stack) {
      state = AsyncValue.error(
        AuthFlowException(_friendlyAuthMessage(e, isSignUp: false)),
        stack,
      );
    }
  }

  Future<String> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    final client = ref.read(supabaseClientProvider);
    final profileService = ref.read(supabaseProfileServiceProvider);

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          if (displayName != null && displayName.trim().isNotEmpty)
            'display_name': displayName.trim(),
        },
      );

      final user = response.user;
      if (user == null) {
        final message = 'Unable to create account.';
        state = AsyncValue.error(message, StackTrace.current);
        throw StateError(message);
      }

      await profileService.ensureProfile(user: user, displayName: displayName);

      if (response.session != null) {
        await client.auth.signOut();
      }

      state = const AsyncValue.data(AuthStatus.unauthenticated);

      if (response.session == null) {
        return 'Account created. Verify your email, then log in.';
      }

      return 'Account created. Please log in.';
    } catch (e, stack) {
      final message = _friendlyAuthMessage(e, isSignUp: true);
      state = AsyncValue.error(AuthFlowException(message), stack);
      throw AuthFlowException(message);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final client = ref.read(supabaseClientProvider);
    await client.auth.signOut();

    state = const AsyncValue.data(AuthStatus.unauthenticated);
  }
}
