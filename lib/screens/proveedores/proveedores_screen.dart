import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  void _mostrarDialogoCrearProveedor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Proveedor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Teléfono(s)'),
                  keyboardType: TextInputType.phone,
                ),
                CheckboxListTile(
                  title: const Text('¿Entrega a domicilio?'),
                  value: false,
                  onChanged: (val) {
                    // TODO: Gestionar estado
                  },
                )
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
      appBar: AppBar(title: const Text('Directorio de Proveedores')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 2, // Simulando datos
        itemBuilder: (context, index) {
          bool delivery = index == 0; // Simulando que el primero tiene delivery
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.business)),
            title: Text('Repuestos ${index == 0 ? 'La Esperanza' : 'El Triunfo'}'),
            subtitle: Text('Tel: 555-010$index'),
            trailing: delivery 
                ? const Tooltip(
                    message: 'Tiene entrega a domicilio',
                    child: Icon(Icons.local_shipping, color: Colors.green),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearProveedor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
