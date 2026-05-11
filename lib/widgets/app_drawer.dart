import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1565C0)),
            child: Text(
              'Taller de Carros',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Panel de Control'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/clientes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Vehículos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/vehiculos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_quote),
            title: const Text('Cotizaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/cotizaciones');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Órdenes de Trabajo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/ordenes');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendario'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/calendario');
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Proveedores'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/proveedores');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_applications),
            title: const Text('Ref. Repuestos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/repuestos_referencia');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/configuracion');
            },
          ),
        ],
      ),
    );
  }
}
