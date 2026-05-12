import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/proveedor.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _entregaDomicilio = false;

  void _mostrarDialogoCrearProveedor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Proveedor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                  TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
                  CheckboxListTile(
                    title: const Text('Entrega a domicilio'),
                    value: _entregaDomicilio,
                    onChanged: (val) => setDialogState(() => _entregaDomicilio = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_nombreController.text.isNotEmpty) {
                      final p = Proveedor(
                        nombre: _nombreController.text,
                        telefono: _telefonoController.text,
                        entregaDomicilio: _entregaDomicilio,
                      );
                      await _supabaseService.insertProveedor(p);
                      _nombreController.clear();
                      _telefonoController.clear();
                      _entregaDomicilio = false;
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
      appBar: AppBar(title: const Text('Proveedores')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Proveedor>>(
        future: _supabaseService.getProveedores(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(p.nombre),
                  subtitle: Text(p.telefono ?? 'Sin teléfono'),
                  trailing: p.entregaDomicilio 
                    ? const Icon(Icons.local_shipping, color: Colors.green)
                    : null,
                ),
              );
            },
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
