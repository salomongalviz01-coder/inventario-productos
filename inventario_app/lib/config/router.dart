import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';
import '../screens/productos_screen.dart';
import '../widgets/app_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/productos',
          builder: (context, state) => const ProductosScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/productos/nuevo',
      builder: (context, state) => const ProductoFormScreen(),
    ),
    GoRoute(
      path: '/productos/:id',
      builder: (context, state) => ProductoDetalleScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/productos/:id/editar',
      builder: (context, state) => ProductoFormScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);