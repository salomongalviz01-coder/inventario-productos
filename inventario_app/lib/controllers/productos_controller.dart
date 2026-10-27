import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/api_service.dart';

class ProductosController extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Producto> productos = [];
  bool cargando = false;
  String? error;

  int get totalProductos => productos.length;

  int get totalUnidades => productos.fold(0, (suma, p) => suma + p.cantidad);

  double get valorInventario =>
      productos.fold(0.0, (suma, p) => suma + p.precio * p.cantidad);

  Future<void> cargar() async {
        await Future<void>.delayed(Duration.zero);
    cargando = true;
    error = null;
    notifyListeners();
    try {
      productos = await _api.listar();
    } on ApiException catch (e) {
      error = e.mensaje;
    } catch (_) {
      error = 'Ocurrió un error inesperado';
    }
    cargando = false;
    notifyListeners();
  }

  Future<Producto> obtener(int id) => _api.obtener(id);

  Future<void> crear(Producto p) async {
    await _api.crear(p);
    await cargar();
  }

  Future<void> actualizar(int id, Producto p) async {
    await _api.actualizar(id, p);
    await cargar();
  }

  Future<void> eliminar(int id) async {
    await _api.eliminar(id);
    await cargar();
  }
}

final productosController = ProductosController();