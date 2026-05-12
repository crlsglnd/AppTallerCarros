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
  final _searchController = TextEditingController();
  
  List<Vehiculo> _allVehiculos = [];
  List<Vehiculo> _filteredVehiculos = [];
  List<Cliente> _allClientes = [];
  Cliente? _clienteSeleccionado;
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterVehiculos);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      final data = await _supabaseService.getVehiculos();
      _allClientes = await _supabaseService.getClientes();
      setState(() {
        _allVehiculos = data;
        _filteredVehiculos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterVehiculos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVehiculos = _allVehiculos.where((v) {
        return v.placa.toLowerCase().contains(query) || 
               v.marca.toLowerCase().contains(query) ||
               v.modelo.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _mostrarDialogoVehiculo({Vehiculo? vehiculo}) {
    if (vehiculo != null) {
      _placaController.text = vehiculo.placa;
      _marcaController.text = vehiculo.marca;
      _modeloController.text = vehiculo.modelo;
      _anioController.text = vehiculo.anio.toString();
      _clienteSeleccionado = _allClientes.cast<Cliente?>().firstWhere((c) => c?.id == vehiculo.clienteId, orElse: () => null);
    } else {
      _placaController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _anioController.clear();
      _clienteSeleccionado = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(vehiculo == null ? 'Nuevo Vehículo' : 'Editar Vehículo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Cliente>(
                      value: _clienteSeleccionado,
                      decoration: const InputDecoration(labelText: 'Propietario'),
                      items: _allClientes.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.nombre),
                      )).toList(),
                      onChanged: (val) => setDialogState(() => _clienteSeleccionado = val),
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
                      try {
                        final v = Vehiculo(
                          id: vehiculo?.id,
                          placa: _placaController.text,
                          marca: _marcaController.text,
                          modelo: _modeloController.text,
                          anio: int.tryParse(_anioController.text) ?? 0,
                          clienteId: _clienteSeleccionado!.id,
                        );
                        if (vehiculo == null) {
                          await _supabaseService.insertVehiculo(v);
                        } else {
                          await _supabaseService.updateVehiculo(v);
                        }
                        if (!mounted) return;
                        Navigator.pop(context);
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vehiculo == null ? 'Vehículo guardado' : 'Vehículo actualizado'), backgroundColor: Colors.green),
                        );
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

  void _confirmarEliminar(Vehiculo v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Vehículo'),
        content: Text('¿Eliminar vehículo placa ${v.placa}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteVehiculo(v.id!);
                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehículo eliminado')));
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
        title: const Text('Vehículos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por placa, marca o modelo...',
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
              : _filteredVehiculos.isEmpty 
                ? const Center(child: Text('No hay vehículos.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filteredVehiculos.length,
                    itemBuilder: (context, index) {
                      final v = _filteredVehiculos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car, size: 32),
                          title: Text('${v.placa} - ${v.marca} ${v.modelo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Año: ${v.anio}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoVehiculo(vehiculo: v)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(v)),
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
        onPressed: () => _mostrarDialogoVehiculo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
