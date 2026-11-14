import 'package:dio/dio.dart';
import '../models/producto.dart';
import 'api_client.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? codigo;
  ApiException(this.mensaje, [this.codigo]);

  @override
  String toString() => mensaje;
}

/// Convierte un error de Dio en un mensaje legible para el usuario.
/// Es pública para que también la use AuthService.
ApiException convertirError(DioException e) {
  final respuesta = e.response;
  if (respuesta == null) {
    return ApiException('No se pudo conectar con el servidor');
  }
  final data = respuesta.data;
  final detalle = data is Map ? data['detail'] : null;
  String mensaje = 'Error ${respuesta.statusCode}';
  if (detalle is String) {
    mensaje = detalle;
  } else if (detalle is List && detalle.isNotEmpty) {
    final primero = detalle.first as Map;
    final campo = (primero['loc'] as List).last;
    mensaje = '$campo: ${primero['msg']}';
  }
  return ApiException(mensaje, respuesta.statusCode);
}

class ApiService {
  // Cliente compartido: ya envía el token JWT y maneja el 401.
  final Dio _dio = ApiClient.dio;

  Future<List<Producto>> listar() async {
    try {
      final r = await _dio.get('/api/productos');
      return (r.data as List).map((j) => Producto.fromJson(j)).toList();
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }

  Future<Producto> obtener(int id) async {
    try {
      final r = await _dio.get('/api/productos/$id');
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }

  Future<Producto> crear(Producto p) async {
    try {
      final r = await _dio.post('/api/productos', data: p.toJson());
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }

  Future<Producto> actualizar(int id, Producto p) async {
    try {
      final r = await _dio.put('/api/productos/$id', data: p.toJson());
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/api/productos/$id');
    } on DioException catch (e) {
      throw convertirError(e);
    }
  }
}