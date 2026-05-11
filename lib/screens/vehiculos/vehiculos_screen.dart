import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class VehiculosScreen extends StatelessWidget {
  const VehiculosScreen({super.key});

  void _mostrarDialogoCrearVehiculo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Vehículo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'ID del Cliente (Identidad)'),
                ),
                TextField(decoration: const InputDecoration(labelText: 'Marca')),
                TextField(decoration: const InputDecoration(labelText: 'Modelo')),
                TextField(decoration: const InputDecoration(labelText: 'Placa')),
                TextField(
                  decoration: const InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                ),
                TextField(decoration: const InputDecoration(labelText: 'Color')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Guardar en Supabase
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 0, // TODO: Cargar datos de Supabase
        itemBuilder: (context, index) {
          return const ListTile(
            title: Text('Placa - Marca Modelo'),
            subtitle: Text('Cliente: Nombre del Cliente'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearVehiculo(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
