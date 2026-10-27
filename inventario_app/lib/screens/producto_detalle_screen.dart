import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/productos_controller.dart';
import '../models/producto.dart';
import '../services/api_service.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final int id;
  const ProductoDetalleScreen({super.key, required this.id});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  late Future<Producto> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = productosController.obtener(widget.id);
  }

  void _recargar() {
    setState(() {
      _futuro = productosController.obtener(widget.id);
    });
  }

  Future<void> _editar(Producto p) async {
    await context.push('/productos/${p.id}/editar');
    if (mounted) _recargar();
  }

  Future<void> _eliminar(Producto p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que deseas eliminar "${p.nombre}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await productosController.eliminar(p.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: ${e.mensaje}')),
      );
    }
  }

  Widget _fila(IconData icono, String etiqueta, String valor) {
    return ListTile(
      leading: Icon(icono),
      title: Text(etiqueta),
      subtitle: Text(valor, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: FutureBuilder<Producto>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final p = snapshot.data!;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Column(
                      children: [
                        _fila(Icons.label, 'Nombre', p.nombre),
                        _fila(Icons.qr_code, 'Código', p.codigo),
                        _fila(Icons.category, 'Categoría', p.categoria),
                        _fila(
                          Icons.notes,
                          'Descripción',
                          (p.descripcion == null || p.descripcion!.isEmpty)
                              ? 'Sin descripción'
                              : p.descripcion!,
                        ),
                        _fila(
                          Icons.attach_money,
                          'Precio',
                          '\$${p.precio.toStringAsFixed(0)}',
                        ),
                        _fila(
                          Icons.inventory,
                          'Cantidad disponible',
                          '${p.cantidad} unidades',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editar(p),
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                          ),
                          onPressed: () => _eliminar(p),
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}