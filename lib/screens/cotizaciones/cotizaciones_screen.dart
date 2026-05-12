import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/cotizacion.dart';
import 'package:app_taller_carros/models/cotizacion_detalle.dart';
import 'package:app_taller_carros/models/vehiculo.dart';
import 'package:app_taller_carros/services/supabase_service.dart';

class CotizacionesScreen extends StatefulWidget {
  const CotizacionesScreen({super.key});

  @override
  State<CotizacionesScreen> createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends State<CotizacionesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final List<CotizacionDetalle> _detallesTemporales = [];
  final _searchController = TextEditingController();
  
  List<Cotizacion> _allCotizaciones = [];
  List<Cotizacion> _filteredCotizaciones = [];
  Vehiculo? _vehiculoSeleccionado;
  final _repuestoNombreController = TextEditingController();
  final _repuestoCostoController = TextEditingController();
  final _manoObraController = TextEditingController();
  
  bool _isLoading = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterCotizaciones);
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _connectionError = null; });
      _allCotizaciones = await _supabaseService.getCotizaciones();
      _filteredCotizaciones = _allCotizaciones;
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _connectionError = e.toString(); });
    }
  }

  void _filterCotizaciones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCotizaciones = _allCotizaciones.where((c) {
        return c.id!.toLowerCase().contains(query) || 
               c.estado.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _mostrarDialogoCrearCotizacion() {
    _detallesTemporales.clear();
    _manoObraController.clear();
    _vehiculoSeleccionado = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nueva Cotización'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<List<Vehiculo>>(
                      future: _supabaseService.getVehiculos(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        return DropdownButtonFormField<Vehiculo>(
                          decoration: const InputDecoration(labelText: 'Seleccionar Vehículo'),
                          items: snapshot.data!.map((v) => DropdownMenuItem(value: v, child: Text(v.placa))).toList(),
                          onChanged: (val) => setDialogState(() => _vehiculoSeleccionado = val),
                        );
                      },
                    ),
                    TextField(controller: _manoObraController, decoration: const InputDecoration(labelText: 'Mano de Obra (\$)'), keyboardType: TextInputType.number),
                    const Divider(),
                    const Text('Agregar Repuesto:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _repuestoNombreController, decoration: const InputDecoration(labelText: 'Nombre Repuesto')),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _repuestoCostoController, decoration: const InputDecoration(labelText: 'Costo (\$)'), keyboardType: TextInputType.number)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            if (_repuestoNombreController.text.isNotEmpty && _repuestoCostoController.text.isNotEmpty) {
                              setDialogState(() {
                                _detallesTemporales.add(CotizacionDetalle(
                                  descripcion: _repuestoNombreController.text,
                                  costo: double.tryParse(_repuestoCostoController.text) ?? 0.0,
                                ));
                                _repuestoNombreController.clear();
                                _repuestoCostoController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._detallesTemporales.map((d) => ListTile(title: Text(d.descripcion), trailing: Text('\$${d.costo}'), dense: true)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_vehiculoSeleccionado != null) {
                      try {
                        double subtotalRepuestos = _detallesTemporales.fold(0, (sum, item) => sum + item.costo);
                        double manoObra = double.tryParse(_manoObraController.text) ?? 0;
                        final nuevaCot = Cotizacion(
                          vehiculoId: _vehiculoSeleccionado!.id!,
                          costoManoObra: manoObra,
                          totalCalculado: subtotalRepuestos + manoObra,
                        );
                        await _supabaseService.insertCotizacion(nuevaCot, _detallesTemporales);
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

  void _confirmarEliminar(Cotizacion c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cotización'),
        content: const Text('¿Estás seguro de eliminar esta cotización?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteCotizacion(c.id!);
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
        title: const Text('Cotizaciones'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cotización...',
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
              : _filteredCotizaciones.isEmpty 
                ? const Center(child: Text('No hay cotizaciones.'))
                : ListView.builder(
                    itemCount: _filteredCotizaciones.length,
                    itemBuilder: (context, index) {
                      final cot = _filteredCotizaciones[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ExpansionTile(
                          title: Text('Cotización #${cot.id?.substring(0,5)} - \$${cot.totalCalculado}'),
                          subtitle: Text(cot.estado),
                          children: [
                            if (cot.detalles != null)
                              ...cot.detalles!.map((d) => ListTile(title: Text(d.descripcion), trailing: Text('\$${d.costo}'), dense: true)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(cot)),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _mostrarDialogoCrearCotizacion, child: const Icon(Icons.add)),
    );
  }
}
