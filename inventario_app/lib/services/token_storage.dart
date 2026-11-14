import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda la sesión del usuario:
/// - access_token  -> flutter_secure_storage (dato sensible, cifrado)
/// - nombre/correo -> shared_preferences (datos no sensibles)
class TokenStorage {
  static const _kAccessToken = 'access_token';
  static const _kNombre = 'usuario_nombre';
  static const _kCorreo = 'usuario_correo';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> guardarSesion({
    required String token,
    required String nombre,
    required String correo,
  }) async {
    await _secure.write(key: _kAccessToken, value: token);
    await guardarUsuario(nombre: nombre, correo: correo);
  }

  Future<void> guardarUsuario({
    required String nombre,
    required String correo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNombre, nombre);
    await prefs.setString(_kCorreo, correo);
  }

  Future<String?> leerToken() => _secure.read(key: _kAccessToken);

  Future<({String? nombre, String? correo})> leerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return (
    nombre: prefs.getString(_kNombre),
    correo: prefs.getString(_kCorreo),
    );
  }

  /// Elimina todos los datos locales de autenticación.
  Future<void> limpiar() async {
    await _secure.delete(key: _kAccessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kNombre);
    await prefs.remove(_kCorreo);
  }
}