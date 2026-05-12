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
  Vehiculo? _vehiculoSeleccionado;
  final _repuestoNombreController = TextEditingController();
  final _repuestoCostoController = TextEditingController();
  final _manoObraController = TextEditingController();

  void _mostrarDialogoCrearCotizacion(BuildContext context) {
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
                          decoration: const InputDecoration(labelText: 'Seleccionar Vehículo (Placa)'),
                          items: snapshot.data!.map((v) => DropdownMenuItem(
                            value: v,
                            child: Text('${v.placa} - ${v.marca} ${v.modelo}'),
                          )).toList(),
                          onChanged: (val) => setDialogState(() => _vehiculoSeleccionado = val),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _manoObraController,
                      decoration: const InputDecoration(labelText: 'Mano de Obra (\$)'),
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(),
                    const Text('Agregar Repuesto:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _repuestoNombreController,
                      decoration: const InputDecoration(labelText: 'Nombre Repuesto'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _repuestoCostoController,
                            decoration: const InputDecoration(labelText: 'Costo (\$)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            if (_repuestoNombreController.text.isNotEmpty && _repuestoCostoController.text.isNotEmpty) {
                              setDialogState(() {
                                _detallesTemporales.add(CotizacionDetalle(
                                  nombre: _repuestoNombreController.text,
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
                    ..._detallesTemporales.map((d) => ListTile(
                      title: Text(d.nombre),
                      trailing: Text('\$${d.costo.toStringAsFixed(2)}'),
                      dense: true,
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (_vehiculoSeleccionado != null) {
                      double subtotalRepuestos = _detallesTemporales.fold(0, (sum, item) => sum + item.costo);
                      double manoObra = double.tryParse(_manoObraController.text) ?? 0;
                      
                      final nuevaCot = Cotizacion(
                        vehiculoId: _vehiculoSeleccionado!.id!,
                        costoManoObra: manoObra,
                        totalBase: subtotalRepuestos + manoObra,
                      );
                      
                      await _supabaseService.insertCotizacion(nuevaCot, _detallesTemporales);
                      if (!mounted) return;
                      _detallesTemporales.clear();
                      _manoObraController.clear();
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text('Guardar Cotización'),
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
      appBar: AppBar(title: const Text('Cotizaciones')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Cotizacion>>(
        future: _supabaseService.getCotizaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data ?? [];
          return list.isEmpty 
            ? const Center(child: Text('No hay cotizaciones registradas.'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final cot = list[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: const Icon(Icons.request_quote, color: Color(0xFF1565C0)),
                      title: Text('Cotización #${cot.id?.substring(0,5) ?? 'N/A'}'),
                      subtitle: Text('Total base: \$${cot.totalBase.toStringAsFixed(2)} - ${cot.estado}'),
                      children: [
                        const Divider(),
                        if (cot.detalles != null)
                          ...cot.detalles!.map((d) => ListTile(
                            title: Text(d.nombre),
                            trailing: Text('\$${d.costo.toStringAsFixed(2)}'),
                            dense: true,
                          )),
                        ListTile(
                          title: const Text('Mano de Obra', style: TextStyle(fontStyle: FontStyle.italic)),
                          trailing: Text('\$${cot.costoManoObra.toStringAsFixed(2)}'),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {}, // TODO: Aceptar lógica
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrearCotizacion(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
