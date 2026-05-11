import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  void _mostrarDialogoCrearCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(decoration: const InputDecoration(labelText: 'Email')),
                TextField(decoration: const InputDecoration(labelText: 'Teléfono')),
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
      appBar: AppBar(title: const Text('Clientes')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 0, // TODO: Cargar datos de Supabase
        itemBuilder: (context, index) {
          return const ListTile(
            title: Text('Nombre del cliente'),
            subtitle: Text('Email o teléfono'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearCliente(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
