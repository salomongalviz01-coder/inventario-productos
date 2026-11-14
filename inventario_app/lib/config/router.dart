import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';
import '../screens/productos_screen.dart';
import '../screens/sesion_screen.dart';
import '../services/auth_service.dart';
import '../widgets/app_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',

  // Cuando AuthService notifica un cambio (login, logout, token vencido),
  // go_router vuelve a evaluar el redirect.
  refreshListenable: AuthService.instance,

  // Control de acceso a las pantallas:
  // - sin sesión  -> cualquier ruta lleva a /login
  // - con sesión  -> /login lleva al dashboard
  redirect: (context, state) {
    final autenticado = AuthService.instance.autenticado;
    final enLogin = state.matchedLocation == '/login';

    if (!autenticado && !enLogin) return '/login';
    if (autenticado && enLogin) return '/';
    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
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
        GoRoute(
          path: '/sesion',
          builder: (context, state) => const SesionScreen(),
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