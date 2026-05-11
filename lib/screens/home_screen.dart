import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildKPI(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigAction(BuildContext context, String title, IconData icon, String route, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcut(BuildContext context, String title, IconData icon, String route) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 28, color: const Color(0xFF1565C0)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taller de Carros')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Hoy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // KPIs
              Row(
                children: [
                  _buildKPI('En Proceso', '8', Colors.orange),
                  const SizedBox(width: 8),
                  _buildKPI('Por Ingresar', '3', Colors.blue),
                  const SizedBox(width: 8),
                  _buildKPI('Por Entregar', '2', Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Acciones Principales',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Botones Grandes
              Row(
                children: [
                  _buildBigAction(context, 'Nueva Cotización', Icons.request_quote, '/cotizaciones', const Color(0xFF8E24AA)),
                  const SizedBox(width: 16),
                  _buildBigAction(context, 'Nueva Orden', Icons.build, '/ordenes', const Color(0xFFF4511E)),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Accesos Rápidos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Shortcuts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShortcut(context, 'Clientes', Icons.people, '/clientes'),
                  _buildShortcut(context, 'Vehículos', Icons.directions_car, '/vehiculos'),
                  _buildShortcut(context, 'Calendario', Icons.calendar_month, '/calendario'),
                  _buildShortcut(context, 'Proveedores', Icons.business, '/proveedores'),
                  _buildShortcut(context, 'Repuestos', Icons.settings_applications, '/repuestos_referencia'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
