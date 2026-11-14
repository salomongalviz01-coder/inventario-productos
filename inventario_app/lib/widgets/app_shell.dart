import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indice(BuildContext context) {
    final ruta = GoRouterState.of(context).uri.path;
    if (ruta.startsWith('/sesion')) return 2;
    if (ruta.startsWith('/productos')) return 1;
    return 0;
  }

  void _ir(BuildContext context, int i) {
    switch (i) {
      case 1:
        context.go('/productos');
      case 2:
        context.go('/sesion');
      default:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice(context),
        onDestinationSelected: (i) => _ir(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Sesión',
          ),
        ],
      ),
    );
  }
}