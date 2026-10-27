import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/productos_controller.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();
    productosController.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/productos/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: ListenableBuilder(
        listenable: productosController,
        builder: (context, _) {
          final c = productosController;

          if (c.cargando && c.productos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.error != null && c.productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(c.error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: c.cargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (c.productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados'));
          }

          return RefreshIndicator(
            onRefresh: c.cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: c.productos.length,
              itemBuilder: (context, i) {
                final p = c.productos[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.inventory_2_outlined),
                    ),
                    title: Text(p.nombre),
                    subtitle: Text('${p.codigo} · ${p.categoria}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${p.precio.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${p.cantidad} uds.'),
                      ],
                    ),
                    onTap: () => context.push('/productos/${p.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}