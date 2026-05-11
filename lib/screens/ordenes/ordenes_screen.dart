import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';

class OrdenesScreen extends StatelessWidget {
  const OrdenesScreen({super.key});

  void _mostrarDialogoCrearOrden(BuildContext context) {
    bool isDateSaturated = true; // Simulación: por defecto decimos que está saturado para mostrar el override

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Orden de Trabajo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'ID del Vehículo'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Descripción del trabajo'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Fecha de Ingreso:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Expanded(child: Text('2026-05-15 (Ejemplo)')),
                    TextButton(
                      onPressed: () {
                        // TODO: Mostrar DatePicker real
                      },
                      child: const Text('Seleccionar'),
                    ),
                  ],
                ),
                if (isDateSaturated)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    child: Column(
                      children: [
                        const Text(
                          'Día sin disponibilidad (Límite alcanzado).',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Lógica de override del lado del taller
                            // Permitir ingreso
                          },
                          icon: const Icon(Icons.warning, size: 16),
                          label: const Text('Forzar Ingreso (+1)', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        )
                      ],
                    ),
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
      appBar: AppBar(title: const Text('Órdenes de Trabajo')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 0, // TODO: Cargar datos de Supabase
        itemBuilder: (context, index) {
          return const ListTile(
            title: Text('Orden # - Vehículo Placa'),
            subtitle: Text('Estado: Pendiente - Ingreso: 2026-05-15'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearOrden(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
