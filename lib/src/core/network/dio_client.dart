import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:takion/src/core/network/auth_service.dart';
import 'package:takion/src/core/network/rate_limit_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://metron.cloud/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Rate limiter should be early in the chain
  dio.interceptors.add(RateLimitInterceptor());

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final authService = ref.read(authServiceProvider);
      final creds = await authService.getCredentials();
      if (creds != null) {
        final auth = 'Basic ${base64Encode(utf8.encode('${creds['username']}:${creds['password']}'))}';
        options.headers['Authorization'] = auth;
      }
      return handler.next(options);
    },
  ));

  return dio;
});
