import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'token_storage.dart';

/// Cliente Dio único para toda la app.
///
/// - Agrega `Authorization: Bearer <token>` a cada petición protegida.
/// - Si la API responde 401 en una petición protegida, avisa a [onUnauthorized]
///   para que la app cierre la sesión y redirija al login.
class ApiClient {
  ApiClient._();

  static final TokenStorage _storage = TokenStorage();

  /// La asigna AuthService. Se ejecuta cuando el backend rechaza el token.
  static void Function()? onUnauthorized;

  /// Se crea la primera vez que se usa (dotenv ya debe estar cargado en main).
  static final Dio dio = _crear();

  /// Para peticiones públicas (login): options: ApiClient.publico
  static final Options publico = Options(extra: {'requiresAuth': false});

  static Dio _crear() {
    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final requiereAuth = options.extra['requiresAuth'] != false;
        if (requiereAuth) {
          final token = await _storage.leerToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final requiereAuth = error.requestOptions.extra['requiresAuth'] != false;
        if (error.response?.statusCode == 401 && requiereAuth) {
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}