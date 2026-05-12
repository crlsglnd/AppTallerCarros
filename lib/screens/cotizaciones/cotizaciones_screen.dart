import 'package:flutter/material.dart';
import 'package:app_taller_carros/widgets/app_drawer.dart';
import 'package:app_taller_carros/models/cotizacion.dart';
import 'package:app_taller_carros/models/cotizacion_detalle.dart';
import 'package:app_taller_carros/models/orden_trabajo.dart';
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
  List<OrdenTrabajo> _allOrdenes = [];
  
  OrdenTrabajo? _ordenSeleccionada;
  final _repuestoNombreController = TextEditingController();
  final _repuestoCostoController = TextEditingController();
  final _manoObraController = TextEditingController();
  final _recargoTarjetaController = TextEditingController(text: '0');
  String _metodoPago = 'Efectivo';
  
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
      _allOrdenes = await _supabaseService.getOrdenes();
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
        return (c.vehiculo?.placa.toLowerCase().contains(query) ?? false) || 
               c.estado.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _mostrarDialogoCotizacion({Cotizacion? cotizacion}) {
    if (cotizacion != null) {
      _detallesTemporales.clear();
      if (cotizacion.detalles != null) _detallesTemporales.addAll(cotizacion.detalles!);
      _manoObraController.text = cotizacion.costoManoObra.toString();
      _recargoTarjetaController.text = cotizacion.porcentajeRecargoTarjeta.toString();
      _metodoPago = cotizacion.metodoPago;
      _ordenSeleccionada = _allOrdenes.cast<OrdenTrabajo?>().firstWhere((o) => o?.id == cotizacion.ordenTrabajoId, orElse: () => null);
    } else {
      _detallesTemporales.clear();
      _manoObraController.clear();
      _recargoTarjetaController.text = '0';
      _metodoPago = 'Efectivo';
      _ordenSeleccionada = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final ordenesDisponibles = _allOrdenes.where((o) => 
                o.estado == 'Pendiente' || o.estado == 'En Progreso').toList();

            double totalRepuestos = _detallesTemporales.fold(0, (sum, item) => sum + item.costo);
            double manoObra = double.tryParse(_manoObraController.text) ?? 0;
            double subtotal = totalRepuestos + manoObra;
            double recargo = _metodoPago == 'Tarjeta' ? (subtotal * (double.tryParse(_recargoTarjetaController.text) ?? 0) / 100) : 0;
            double totalFinal = subtotal + recargo;

            return AlertDialog(
              title: Text(cotizacion == null ? 'Nueva Cotización' : 'Editar Cotización'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<OrdenTrabajo>(
                      value: _ordenSeleccionada != null && (ordenesDisponibles.any((o) => o.id == _ordenSeleccionada!.id) || cotizacion != null)
                          ? _allOrdenes.firstWhere((o) => o.id == _ordenSeleccionada!.id)
                          : null,
                      decoration: const InputDecoration(labelText: 'Orden de Trabajo Activa'),
                      items: (cotizacion == null ? ordenesDisponibles : _allOrdenes).map((o) => DropdownMenuItem(
                        value: o,
                        child: Text('${o.vehiculo?.placa ?? 'N/A'} - #${o.id?.substring(0,5)}'),
                      )).toList(),
                      onChanged: (val) => setDialogState(() => _ordenSeleccionada = val),
                    ),
                    const SizedBox(height: 16),
                    // MÉTODO DE PAGO CORREGIDO
                    DropdownButtonFormField<String>(
                      value: _metodoPago,
                      decoration: const InputDecoration(labelText: 'Método de Pago'),
                      items: const [
                        DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          _metodoPago = val!;
                        });
                      },
                    ),
                    if (_metodoPago == 'Tarjeta')
                      TextField(
                        controller: _recargoTarjetaController,
                        decoration: const InputDecoration(labelText: 'Recargo Tarjeta (%)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    TextField(
                      controller: _manoObraController,
                      decoration: const InputDecoration(labelText: 'Mano de Obra (\$)'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const Divider(),
                    const Text('Repuestos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._detallesTemporales.asMap().entries.map((entry) => ListTile(
                      title: Text(entry.value.descripcion),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${entry.value.costo}'),
                          IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setDialogState(() => _detallesTemporales.removeAt(entry.key))),
                        ],
                      ),
                      dense: true,
                    )),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _repuestoNombreController, decoration: const InputDecoration(labelText: 'Nuevo Repuesto'))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _repuestoCostoController, decoration: const InputDecoration(labelText: 'Costo'), keyboardType: TextInputType.number)),
                        IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: () {
                          if (_repuestoNombreController.text.isNotEmpty) {
                            setDialogState(() {
                              _detallesTemporales.add(CotizacionDetalle(descripcion: _repuestoNombreController.text, costo: double.tryParse(_repuestoCostoController.text) ?? 0));
                              _repuestoNombreController.clear();
                              _repuestoCostoController.clear();
                            });
                          }
                        }),
                      ],
                    ),
                    const Divider(),
                    Text('Total: \$${totalFinal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_ordenSeleccionada != null) {
                      try {
                        final nuevaCot = Cotizacion(
                          id: cotizacion?.id,
                          vehiculoId: _ordenSeleccionada!.vehiculoId,
                          ordenTrabajoId: _ordenSeleccionada!.id,
                          costoManoObra: manoObra,
                          metodoPago: _metodoPago,
                          porcentajeRecargoTarjeta: double.tryParse(_recargoTarjetaController.text) ?? 0,
                          totalCalculado: totalFinal,
                        );
                        if (cotizacion == null) {
                          await _supabaseService.insertCotizacion(nuevaCot, _detallesTemporales);
                        } else {
                          await _supabaseService.deleteCotizacion(cotizacion.id!);
                          await _supabaseService.insertCotizacion(nuevaCot, _detallesTemporales);
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

  void _cambiarEstado(Cotizacion c, String nuevoEstado) async {
    try {
      // 1. Cambiar estado de la cotización seleccionada
      await _supabaseService.updateCotizacionEstado(c.id!, nuevoEstado);
      
      if (nuevoEstado == 'Aceptada') {
        // 2. Si hay más cotizaciones pendientes para esta misma orden, se rechazan automáticamente
        if (c.ordenTrabajoId != null) {
          await _supabaseService.rechazarOtrasCotizaciones(c.ordenTrabajoId!, c.id!);
          
          // 3. Pasar la orden de trabajo a "En Progreso"
          final orden = _allOrdenes.firstWhere((o) => o.id == c.ordenTrabajoId);
          final ordenActualizada = OrdenTrabajo(
            id: orden.id,
            vehiculoId: orden.vehiculoId,
            descripcion: orden.descripcion,
            estado: 'En Progreso',
            fechaIngreso: orden.fechaIngreso,
          );
          await _supabaseService.updateOrden(ordenActualizada);
        }
      }

      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
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
                hintText: 'Buscar por placa o estado...',
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
                          leading: const Icon(Icons.request_quote, color: Colors.blue),
                          title: Text('Placa: ${cot.vehiculo?.placa ?? 'N/A'} - \$${cot.totalCalculado.toStringAsFixed(2)}'),
                          subtitle: Text('Estado: ${cot.estado} • ${cot.metodoPago}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoCotizacion(cotizacion: cot)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _supabaseService.deleteCotizacion(cot.id!).then((_) => _loadData())),
                            ],
                          ),
                          children: [
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mano de Obra: \$${cot.costoManoObra}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (cot.detalles != null)
                                    ...cot.detalles!.map((d) => ListTile(title: Text(d.descripcion), trailing: Text('\$${d.costo}'), dense: true)),
                                  if (cot.porcentajeRecargoTarjeta > 0)
                                    Text('Recargo Tarjeta (${cot.porcentajeRecargoTarjeta}%): \$${(cot.totalCalculado - (cot.costoManoObra + cot.detalles!.fold(0, (s, i) => s + i.costo))).toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            if (cot.estado == 'Pendiente')
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _cambiarEstado(cot, 'Aceptada'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Aceptar'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _cambiarEstado(cot, 'Declinada'),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Rechazar'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _mostrarDialogoCotizacion(), child: const Icon(Icons.add)),
    );
  }
}
