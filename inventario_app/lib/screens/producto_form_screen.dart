import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../controllers/productos_controller.dart';
import '../models/producto.dart';
import '../services/api_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final int? id;
  const ProductoFormScreen({super.key, this.id});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _codigo = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio = TextEditingController();
  final _cantidad = TextEditingController();
  final _categoria = TextEditingController();

  bool _cargando = false;
  bool _guardando = false;
  String? _errorCarga;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) _cargarProducto();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _codigo.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _cantidad.dispose();
    _categoria.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final p = await productosController.obtener(widget.id!);
      _nombre.text = p.nombre;
      _codigo.text = p.codigo;
      _descripcion.text = p.descripcion ?? '';
      _precio.text = p.precio.toString();
      _cantidad.text = p.cantidad.toString();
      _categoria.text = p.categoria;
    } on ApiException catch (e) {
      _errorCarga = e.mensaje;
    } catch (_) {
      _errorCarga = 'Ocurrió un error inesperado';
    }
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final descripcion = _descripcion.text.trim();
    final producto = Producto(
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim(),
      descripcion: descripcion.isEmpty ? null : descripcion,
      precio: double.parse(_precio.text.trim()),
      cantidad: int.parse(_cantidad.text.trim()),
      categoria: _categoria.text.trim(),
    );

    try {
      if (_esEdicion) {
        await productosController.actualizar(widget.id!, producto);
      } else {
        await productosController.crear(producto);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_esEdicion
              ? 'Producto actualizado correctamente'
              : 'Producto registrado correctamente'),
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: ${e.mensaje}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado')),
      );
    }
  }

  String? _requerido(String? v, String campo) {
    if (v == null || v.trim().isEmpty) return 'Ingresa $campo';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: _cuerpo(),
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorCarga != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(_errorCarga!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _cargarProducto,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _requerido(v, 'el nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigo,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _requerido(v, 'el código'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _requerido(v, 'la categoría'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcion,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precio,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null) return 'Ingresa un precio válido';
                  if (n <= 0) return 'El precio debe ser mayor que 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidad,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Ingresa una cantidad válida';
                  if (n < 0) return 'La cantidad no puede ser negativa';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_esEdicion ? 'Guardar cambios' : 'Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}