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
  final _searchController = TextEditingController();
  
  List<OrdenTrabajo> _allOrdenes = [];
  List<OrdenTrabajo> _filteredOrdenes = [];
  List<Vehiculo> _allVehiculos = [];
  Vehiculo? _vehiculoSeleccionado;
  DateTime _fechaSeleccionada = DateTime.now();
  String _estadoSeleccionado = 'Pendiente';
  
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterOrdenes);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      _allOrdenes = await _supabaseService.getOrdenes();
      _allVehiculos = await _supabaseService.getVehiculos();
      _filteredOrdenes = _allOrdenes;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterOrdenes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrdenes = _allOrdenes.where((o) {
        return o.descripcion.toLowerCase().contains(query) || 
               o.estado.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _mostrarDialogoOrden({OrdenTrabajo? orden}) {
    if (orden != null) {
      _descripcionController.text = orden.descripcion;
      _fechaSeleccionada = orden.fechaIngreso ?? DateTime.now();
      _estadoSeleccionado = orden.estado;
      _vehiculoSeleccionado = _allVehiculos.cast<Vehiculo?>().firstWhere((v) => v?.id == orden.vehiculoId, orElse: () => null);
    } else {
      _descripcionController.clear();
      _fechaSeleccionada = DateTime.now();
      _estadoSeleccionado = 'Pendiente';
      _vehiculoSeleccionado = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(orden == null ? 'Nueva Orden' : 'Editar Orden'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Vehiculo>(
                      value: _vehiculoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                      items: _allVehiculos.map((v) => DropdownMenuItem(value: v, child: Text(v.placa))).toList(),
                      onChanged: (val) => setDialogState(() => _vehiculoSeleccionado = val),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: ['Pendiente', 'En Progreso', 'Completada'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setDialogState(() => _estadoSeleccionado = val!),
                    ),
                    TextField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fecha Ingreso'),
                      subtitle: Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
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
                      try {
                        final o = OrdenTrabajo(
                          id: orden?.id,
                          vehiculoId: _vehiculoSeleccionado!.id!,
                          descripcion: _descripcionController.text,
                          fechaIngreso: _fechaSeleccionada,
                          estado: _estadoSeleccionado,
                        );
                        if (orden == null) {
                          await _supabaseService.insertOrden(o);
                        } else {
                          await _supabaseService.updateOrden(o);
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

  void _confirmarEliminar(OrdenTrabajo o) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Orden'),
        content: const Text('¿Eliminar esta orden de trabajo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteOrden(o.id!);
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
        title: const Text('Órdenes de Trabajo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por descripción o estado...',
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
              : _filteredOrdenes.isEmpty 
                ? const Center(child: Text('No hay órdenes.'))
                : ListView.builder(
                    itemCount: _filteredOrdenes.length,
                    itemBuilder: (context, index) {
                      final o = _filteredOrdenes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.build, color: o.estado == 'Pendiente' ? Colors.orange : Colors.green),
                          title: Text('Orden #${o.id?.substring(0,5) ?? 'N/A'}'),
                          subtitle: Text('${o.descripcion}\n${o.estado}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoOrden(orden: o)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(o)),
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
        onPressed: () => _mostrarDialogoOrden(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
