import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class RepuestosReferenciaScreen extends StatelessWidget {
  const RepuestosReferenciaScreen({super.key});

  void _mostrarDialogoCrearReferencia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Referencia de Repuesto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Nombre del repuesto'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Marca aplicable (Ej. Toyota)'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Modelo aplicable (Ej. Corolla)'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Años aplicables (Ej. 2015-2020)'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Valor Referencial (\$)'),
                  keyboardType: TextInputType.number,
                ),
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
      appBar: AppBar(title: const Text('Base de Repuestos')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 2, // Simulando datos
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.settings)),
            title: Text(index == 0 ? 'Filtro de Aceite' : 'Pastillas de Freno'),
            subtitle: Text(index == 0 ? 'Toyota Corolla (2015-2020)' : 'Honda Civic (2018-2022)'),
            trailing: Text(
              '\$${index == 0 ? 15.00 : 45.00}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearReferencia(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
