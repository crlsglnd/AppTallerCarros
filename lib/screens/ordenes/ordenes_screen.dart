import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/orden_trabajo.dart';
import 'package:app_taller_carros/models/vehiculo.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _descripcionController = TextEditingController();
  Vehiculo? _vehiculoSeleccionado;
  DateTime _fechaSeleccionada = DateTime.now();

  void _mostrarDialogoCrearOrden(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva Orden de Trabajo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<List<Vehiculo>>(
                      future: _supabaseService.getVehiculos(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        return DropdownButtonFormField<Vehiculo>(
                          decoration: const InputDecoration(labelText: 'Vehículo (Placa)'),
                          items: snapshot.data!.map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v.placa),
                          )).toList(),
                          onChanged: (val) => setDialogState(() => _vehiculoSeleccionado = val),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción del problema'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Fecha de Ingreso'),
                      subtitle: Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setDialogState(() => _fechaSeleccionada = picked);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_vehiculoSeleccionado != null && _descripcionController.text.isNotEmpty) {
                      final nuevaOrden = OrdenTrabajo(
                        vehiculoId: _vehiculoSeleccionado!.id!,
                        descripcion: _descripcionController.text,
                        fechaIngreso: _fechaSeleccionada,
                        estado: 'Pendiente',
                      );
                    await _supabaseService.insertOrden(nuevaOrden);
                    if (!mounted) return;
                    _descripcionController.clear();
                    Navigator.pop(context);
                    setState(() {});
                    }
                  },
                  child: const Text('Guardar Orden'),
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
      appBar: AppBar(title: const Text('Órdenes de Trabajo')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<OrdenTrabajo>>(
        future: _supabaseService.getOrdenes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final o = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.build, color: o.estado == 'Pendiente' ? Colors.orange : Colors.green),
                  title: Text('Orden #${o.id?.substring(0,5)} - Vehículo ID: ${o.vehiculoId.substring(0,5)}'),
                  subtitle: Text('${o.descripcion}\nFecha: ${o.fechaIngreso?.day}/${o.fechaIngreso?.month}/${o.fechaIngreso?.year}'),
                  trailing: Text(o.estado, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
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
