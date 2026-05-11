import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller de Carros'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clientes'),
              onTap: () => Navigator.pushNamed(context, '/clientes'),
            ),
            ListTile(
              leading: const Icon(Icons.car_repair),
              title: const Text('Vehículos'),
              onTap: () => Navigator.pushNamed(context, '/vehiculos'),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Órdenes'),
              onTap: () => Navigator.pushNamed(context, '/ordenes'),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventario'),
              onTap: () => Navigator.pushNamed(context, '/inventario'),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Bienvenido al Taller de Carros'),
      ),
    );
  }
}
