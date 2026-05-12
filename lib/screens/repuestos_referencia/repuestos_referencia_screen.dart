import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/repuesto_referencia.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class RepuestosReferenciaScreen extends StatefulWidget {
  const RepuestosReferenciaScreen({super.key});

  @override
  State<RepuestosReferenciaScreen> createState() => _RepuestosReferenciaScreenState();
}

class _RepuestosReferenciaScreenState extends State<RepuestosReferenciaScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _nombreController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _aniosController = TextEditingController();
  final _precioController = TextEditingController();

  void _mostrarDialogoCrearRepuesto(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Repuesto de Referencia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: _marcaController, decoration: const InputDecoration(labelText: 'Marca')),
                TextField(controller: _modeloController, decoration: const InputDecoration(labelText: 'Modelo')),
                TextField(controller: _aniosController, decoration: const InputDecoration(labelText: 'Años (ej. 2010-2015)')),
                TextField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio Referencial'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_nombreController.text.isNotEmpty) {
                  final r = RepuestoReferencia(
                    nombre: _nombreController.text,
                    marcaAplicable: _marcaController.text,
                    modeloAplicable: _modeloController.text,
                    aniosAplicables: _aniosController.text,
                    precioReferencia: double.tryParse(_precioController.text) ?? 0.0,
                  );
                  await _supabaseService.insertRepuestoReferencia(r);
                  _nombreController.clear();
                  _marcaController.clear();
                  _modeloController.clear();
                  _aniosController.clear();
                  _precioController.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ref. Repuestos')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<RepuestoReferencia>>(
        future: _supabaseService.getRepuestosReferencia(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final r = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.settings_applications),
                  title: Text(r.nombre),
                  subtitle: Text('${r.marcaAplicable} ${r.modeloAplicable} (${r.aniosAplicables})'),
                  trailing: Text('\$${r.precioReferencia.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearRepuesto(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
