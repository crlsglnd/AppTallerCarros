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
  final _searchController = TextEditingController();
  bool _entregaDomicilio = false;
  
  List<Proveedor> _allProveedores = [];
  List<Proveedor> _filteredProveedores = [];
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterProveedores);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      _allProveedores = await _supabaseService.getProveedores();
      _filteredProveedores = _allProveedores;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterProveedores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProveedores = _allProveedores.where((p) => p.nombre.toLowerCase().contains(query)).toList();
    });
  }

  void _mostrarDialogoProveedor({Proveedor? proveedor}) {
    if (proveedor != null) {
      _nombreController.text = proveedor.nombre;
      _telefonoController.text = proveedor.telefono ?? '';
      _entregaDomicilio = proveedor.entregaDomicilio;
    } else {
      _nombreController.clear();
      _telefonoController.clear();
      _entregaDomicilio = false;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(proveedor == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
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
                      try {
                        final p = Proveedor(
                          id: proveedor?.id,
                          nombre: _nombreController.text,
                          telefono: _telefonoController.text,
                          entregaDomicilio: _entregaDomicilio,
                        );
                        if (proveedor == null) {
                          await _supabaseService.insertProveedor(p);
                        } else {
                          await _supabaseService.updateProveedor(p);
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        _loadData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
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

  void _confirmarEliminar(Proveedor p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Eliminar al proveedor ${p.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteProveedor(p.id!);
                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proveedor...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: _connectionError == null ? Colors.green : Colors.red,
            child: Text(
              _connectionError == null ? 'ONLINE' : 'OFFLINE',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredProveedores.isEmpty 
                ? const Center(child: Text('No hay proveedores.'))
                : ListView.builder(
                    itemCount: _filteredProveedores.length,
                    itemBuilder: (context, index) {
                      final p = _filteredProveedores[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.business),
                          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(p.telefono ?? 'Sin teléfono'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoProveedor(proveedor: p)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(p)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoProveedor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
