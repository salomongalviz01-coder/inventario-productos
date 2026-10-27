import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/productos_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    productosController.cargar();
  }

  String _formatoMiles(num valor) {
    return valor
        .round()
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2),
            SizedBox(width: 8),
            Text('Inventario'),
          ],
        ),
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TarjetaDato(
                    icono: Icons.category,
                    titulo: 'Total de productos',
                    valor: '${c.totalProductos}',
                  ),
                  _TarjetaDato(
                    icono: Icons.inventory,
                    titulo: 'Unidades disponibles',
                    valor: _formatoMiles(c.totalUnidades),
                  ),
                  _TarjetaDato(
                    icono: Icons.attach_money,
                    titulo: 'Valor total del inventario',
                    valor: '\$${_formatoMiles(c.valorInventario)}',
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.go('/productos'),
                    icon: const Icon(Icons.list),
                    label: const Text('Gestionar productos'),
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

class _TarjetaDato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _TarjetaDato({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icono, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}