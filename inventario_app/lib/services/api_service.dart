import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/producto.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? codigo;
  ApiException(this.mensaje, [this.codigo]);

  @override
  String toString() => mensaje;
}

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:8000',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ));

  ApiException _convertirError(DioException e) {
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

  Future<List<Producto>> listar() async {
    try {
      final r = await _dio.get('/api/productos');
      return (r.data as List).map((j) => Producto.fromJson(j)).toList();
    } on DioException catch (e) {
      throw _convertirError(e);
    }
  }

  Future<Producto> obtener(int id) async {
    try {
      final r = await _dio.get('/api/productos/$id');
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw _convertirError(e);
    }
  }

  Future<Producto> crear(Producto p) async {
    try {
      final r = await _dio.post('/api/productos', data: p.toJson());
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw _convertirError(e);
    }
  }

  Future<Producto> actualizar(int id, Producto p) async {
    try {
      final r = await _dio.put('/api/productos/$id', data: p.toJson());
      return Producto.fromJson(r.data);
    } on DioException catch (e) {
      throw _convertirError(e);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/api/productos/$id');
    } on DioException catch (e) {
      throw _convertirError(e);
    }
  }
}