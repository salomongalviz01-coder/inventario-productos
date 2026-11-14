import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_service.dart' show ApiException, convertirError;
import 'token_storage.dart';

/// Maneja login, logout y estado de la sesión.
/// Es un ChangeNotifier para que go_router (refreshListenable) y las
/// pantallas se actualicen cuando cambie la sesión.
class AuthService extends ChangeNotifier {
  AuthService._() {
    ApiClient.onUnauthorized = _sesionExpirada;
  }

  static final AuthService instance = AuthService._();

  final TokenStorage _storage = TokenStorage();

  bool _inicializado = false;
  bool _autenticado = false;
  bool _tieneToken = false;
  String? _nombre;
  String? _correo;

  /// Mensaje para mostrar en el login (ej: "Tu sesión expiró").
  String? mensajeSesion;

  bool get inicializado => _inicializado;
  bool get autenticado => _autenticado;
  bool get tieneToken => _tieneToken;
  String? get nombre => _nombre;
  String? get correo => _correo;

  /// Se llama una vez en main() antes de runApp: recupera la sesión guardada
  /// y la valida contra el backend (GET /api/auth/me).
  Future<void> iniciar() async {
    final token = await _storage.leerToken();

    if (token == null || token.isEmpty) {
      _reiniciarEstado();
      _inicializado = true;
      notifyListeners();
      return;
    }

    try {
      final r = await ApiClient.dio.get('/api/auth/me');
      final data = r.data as Map<String, dynamic>;
      _nombre = data['nombre'] as String?;
      _correo = data['correo'] as String?;
      await _storage.guardarUsuario(
        nombre: _nombre ?? '',
        correo: _correo ?? '',
      );
      _tieneToken = true;
      _autenticado = true;
    } on DioException catch (e) {
      final codigo = e.response?.statusCode;
      if (codigo == 401 || codigo == 403) {
        // Token vencido o inválido: se limpia todo.
        await _storage.limpiar();
        _reiniciarEstado();
      } else {
        // Sin conexión con el servidor: se conserva la sesión guardada.
        final u = await _storage.leerUsuario();
        _nombre = u.nombre;
        _correo = u.correo;
        _tieneToken = true;
        _autenticado = true;
      }
    }

    _inicializado = true;
    notifyListeners();
  }

  /// POST /api/auth/login. Lanza [ApiException] si falla.
  Future<void> login(String correo, String password) async {
    try {
      final r = await ApiClient.dio.post(
        '/api/auth/login',
        data: {'correo': correo.trim(), 'password': password},
        options: ApiClient.publico,
      );

      final data = r.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final usuario = data['usuario'] as Map<String, dynamic>;

      _nombre = usuario['nombre'] as String?;
      _correo = usuario['correo'] as String?;

      await _storage.guardarSesion(
        token: token,
        nombre: _nombre ?? '',
        correo: _correo ?? '',
      );

      mensajeSesion = null;
      _tieneToken = true;
      _autenticado = true;
      notifyListeners();
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }

  /// Cierre de sesión manual: borra token y datos locales.
  Future<void> logout() async {
    await _storage.limpiar();
    _reiniciarEstado();
    mensajeSesion = null;
    notifyListeners();
  }

  /// La llama el interceptor cuando la API responde 401.
  Future<void> _sesionExpirada() async {
    if (!_autenticado) return;
    await _storage.limpiar();
    _reiniciarEstado();
    mensajeSesion = 'Tu sesión expiró. Inicia sesión nuevamente.';
    notifyListeners();
  }

  void _reiniciarEstado() {
    _autenticado = false;
    _tieneToken = false;
    _nombre = null;
    _correo = null;
  }
}