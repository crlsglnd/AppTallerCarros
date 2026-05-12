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
  final _anioController = TextEditingController();
  final _precioController = TextEditingController();
  final _searchController = TextEditingController();

  List<RepuestoReferencia> _allRepuestos = [];
  List<RepuestoReferencia> _filteredRepuestos = [];
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterRepuestos);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      _allRepuestos = await _supabaseService.getRepuestosReferencia();
      _filteredRepuestos = _allRepuestos;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterRepuestos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRepuestos = _allRepuestos.where((r) => r.nombre.toLowerCase().contains(query) || r.marcaAplicable.toLowerCase().contains(query)).toList();
    });
  }

  void _mostrarDialogoRepuesto({RepuestoReferencia? repuesto}) {
    if (repuesto != null) {
      _nombreController.text = repuesto.nombre;
      _marcaController.text = repuesto.marcaAplicable;
      _modeloController.text = repuesto.modeloAplicable;
      _anioController.text = repuesto.aniosAplicables;
      _precioController.text = repuesto.precioReferencia.toString();
    } else {
      _nombreController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _anioController.clear();
      _precioController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(repuesto == null ? 'Nuevo Repuesto' : 'Editar Repuesto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre Repuesto')),
              TextField(controller: _marcaController, decoration: const InputDecoration(labelText: 'Marca Aplicable')),
              TextField(controller: _modeloController, decoration: const InputDecoration(labelText: 'Modelo Aplicable')),
              TextField(controller: _anioController, decoration: const InputDecoration(labelText: 'Años (ej. 2015-2020)')),
              TextField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio Referencia'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_nombreController.text.isNotEmpty) {
                try {
                  final r = RepuestoReferencia(
                    id: repuesto?.id,
                    nombre: _nombreController.text,
                    marcaAplicable: _marcaController.text,
                    modeloAplicable: _modeloController.text,
                    aniosAplicables: _anioController.text,
                    precioReferencia: double.tryParse(_precioController.text) ?? 0,
                  );
                  if (repuesto == null) {
                    await _supabaseService.insertRepuestoReferencia(r);
                  } else {
                    await _supabaseService.updateRepuestoReferencia(r);
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
      ),
    );
  }

  void _confirmarEliminar(RepuestoReferencia r) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Referencia'),
        content: Text('¿Eliminar repuesto ${r.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteRepuestoReferencia(r.id!);
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
        title: const Text('Referencias de Repuestos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o marca...',
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
              : _filteredRepuestos.isEmpty 
                ? const Center(child: Text('No hay repuestos registrados.'))
                : ListView.builder(
                    itemCount: _filteredRepuestos.length,
                    itemBuilder: (context, index) {
                      final r = _filteredRepuestos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.settings_applications),
                          title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${r.marcaAplicable} ${r.modeloAplicable} (${r.aniosAplicables})'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${r.precioReferencia}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoRepuesto(repuesto: r)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(r)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _mostrarDialogoRepuesto(), child: const Icon(Icons.add)),
    );
  }
}
