import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Muestra los datos de la sesión actual (punto 2.5 del taller).
/// Nunca muestra el contenido del token, solo si existe.
class SesionScreen extends StatelessWidget {
  const SesionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Información de sesión')),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) {
          final activa = auth.autenticado;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Nombre'),
                      subtitle: Text(auth.nombre ?? '—'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Correo electrónico'),
                      subtitle: Text(auth.correo ?? '—'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        activa ? Icons.check_circle : Icons.cancel,
                        color: activa ? Colors.green : Colors.red,
                      ),
                      title: const Text('Estado de autenticación'),
                      subtitle: Text(activa ? 'Sesión activa' : 'Sin sesión'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Token almacenado'),
                      subtitle: Text(
                        auth.tieneToken
                            ? 'Sí • guardado de forma segura (••••••••)'
                            : 'No hay token almacenado',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  // Borra token y datos locales; go_router redirige al login.
                  await auth.logout();
                },
                icon: const Icon(Icons.logout),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Cerrar sesión'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}