import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/vehiculo.dart';
import 'package:app_taller_carros/models/cliente.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  Cliente? _clienteSeleccionado;

  void _mostrarDialogoCrearVehiculo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Vehículo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<List<Cliente>>(
                      future: _supabaseService.getClientes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        return DropdownButtonFormField<Cliente>(
                          decoration: const InputDecoration(labelText: 'Propietario'),
                          items: snapshot.data!.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre),
                          )).toList(),
                          onChanged: (val) => setDialogState(() => _clienteSeleccionado = val),
                        );
                      },
                    ),
                    TextField(controller: _placaController, decoration: const InputDecoration(labelText: 'Placa')),
                    TextField(controller: _marcaController, decoration: const InputDecoration(labelText: 'Marca')),
                    TextField(controller: _modeloController, decoration: const InputDecoration(labelText: 'Modelo')),
                    TextField(controller: _anioController, decoration: const InputDecoration(labelText: 'Año'), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_clienteSeleccionado != null && _placaController.text.isNotEmpty) {
                      final nuevoVeh = Vehiculo(
                        placa: _placaController.text,
                        marca: _marcaController.text,
                        modelo: _modeloController.text,
                        anio: int.tryParse(_anioController.text) ?? 0,
                        clienteId: _clienteSeleccionado!.id,
                      );
                      await _supabaseService.insertVehiculo(nuevoVeh);
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Vehiculo>>(
        future: _supabaseService.getVehiculos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final v = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text('${v.placa} - ${v.marca} ${v.modelo}'),
                  subtitle: Text('Dueño ID: ${v.clienteId}'),
                ),
              );
            },
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
