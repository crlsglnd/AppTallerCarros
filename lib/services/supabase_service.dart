import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';
import '../models/cotizacion.dart';
import '../models/cotizacion_detalle.dart';
import '../models/orden_trabajo.dart';
import '../models/proveedor.dart';
import '../models/repuesto_referencia.dart';
import '../models/configuracion_taller.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // CLIENTES
  Future<List<Cliente>> getClientes() async {
    final response = await _client.from('clientes').select().order('nombre');
    return (response as List).map((json) => Cliente.fromJson(json)).toList();
  }

  Future<void> insertCliente(Cliente cliente) async {
    await _client.from('clientes').insert(cliente.toJson());
  }

  Future<void> updateCliente(Cliente cliente) async {
    await _client.from('clientes').update(cliente.toJson()).eq('id', cliente.id);
  }

  Future<void> deleteCliente(String id) async {
    await _client.from('clientes').delete().eq('id', id);
  }

  // VEHICULOS
  Future<List<Vehiculo>> getVehiculos() async {
    final response = await _client.from('vehiculos').select().order('placa');
    return (response as List).map((json) => Vehiculo.fromJson(json)).toList();
  }

  Future<void> insertVehiculo(Vehiculo vehiculo) async {
    await _client.from('vehiculos').insert(vehiculo.toJson());
  }

  Future<void> updateVehiculo(Vehiculo vehiculo) async {
    await _client.from('vehiculos').update(vehiculo.toJson()).eq('id', vehiculo.id!);
  }

  Future<void> deleteVehiculo(String id) async {
    await _client.from('vehiculos').delete().eq('id', id);
  }

  // COTIZACIONES
  Future<List<Cotizacion>> getCotizaciones() async {
    final response = await _client.from('cotizaciones').select('*, cotizacion_detalles(*)').order('created_at', ascending: false);
    return (response as List).map((json) => Cotizacion.fromJson(json)).toList();
  }

  Future<void> insertCotizacion(Cotizacion cotizacion, List<CotizacionDetalle> detalles) async {
    final cotResp = await _client.from('cotizaciones').insert(cotizacion.toJson()).select().single();
    final String cotId = cotResp['id'];
    
    for (var detalle in detalles) {
      await _client.from('cotizacion_detalles').insert({
        ...detalle.toJson(),
        'cotizacion_id': cotId,
      });
    }
  }

  Future<void> deleteCotizacion(String id) async {
    await _client.from('cotizaciones').delete().eq('id', id);
  }

  // ORDENES
  Future<List<OrdenTrabajo>> getOrdenes() async {
    final response = await _client.from('ordenes_trabajo').select().order('fecha_ingreso', ascending: false);
    return (response as List).map((json) => OrdenTrabajo.fromJson(json)).toList();
  }

  Future<void> insertOrden(OrdenTrabajo orden) async {
    await _client.from('ordenes_trabajo').insert(orden.toJson());
  }

  Future<void> updateOrden(OrdenTrabajo orden) async {
    await _client.from('ordenes_trabajo').update(orden.toJson()).eq('id', orden.id!);
  }

  Future<void> deleteOrden(String id) async {
    await _client.from('ordenes_trabajo').delete().eq('id', id);
  }

  // PROVEEDORES
  Future<List<Proveedor>> getProveedores() async {
    final response = await _client.from('proveedores').select().order('nombre');
    return (response as List).map((json) => Proveedor.fromJson(json)).toList();
  }

  Future<void> insertProveedor(Proveedor proveedor) async {
    await _client.from('proveedores').insert(proveedor.toJson());
  }

  Future<void> updateProveedor(Proveedor proveedor) async {
    await _client.from('proveedores').update(proveedor.toJson()).eq('id', proveedor.id!);
  }

  Future<void> deleteProveedor(String id) async {
    await _client.from('proveedores').delete().eq('id', id);
  }

  // REPUESTOS REFERENCIA
  Future<List<RepuestoReferencia>> getRepuestosReferencia() async {
    final response = await _client.from('repuestos_referencia').select().order('nombre');
    return (response as List).map((json) => RepuestoReferencia.fromJson(json)).toList();
  }

  Future<void> insertRepuestoReferencia(RepuestoReferencia repuesto) async {
    await _client.from('repuestos_referencia').insert(repuesto.toJson());
  }

  Future<void> updateRepuestoReferencia(RepuestoReferencia repuesto) async {
    await _client.from('repuestos_referencia').update(repuesto.toJson()).eq('id', repuesto.id!);
  }

  Future<void> deleteRepuestoReferencia(String id) async {
    await _client.from('repuestos_referencia').delete().eq('id', id);
  }

  // CONFIGURACION
  Future<List<ConfiguracionTaller>> getConfiguracion() async {
    var response = await _client.from('configuracion_taller').select().order('id');
    if ((response as List).isEmpty) {
      final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      for (var dia in dias) {
        await _client.from('configuracion_taller').insert({
          'dia_semana': dia,
          'max_ingresos_diarios': 5,
          'hora_apertura': '08:00',
          'hora_cierre': '17:00',
          'esta_abierto': dia != 'Domingo',
        });
      }
      response = await _client.from('configuracion_taller').select().order('id');
    }
    return (response as List).map((json) => ConfiguracionTaller.fromJson(json)).toList();
  }

  Future<void> updateConfiguracionDia(ConfiguracionTaller config) async {
    await _client.from('configuracion_taller').update(config.toJson()).eq('dia_semana', config.diaSemana);
  }

  // KPIs
  Future<Map<String, int>> getKPIs() async {
    final response = await _client.from('ordenes_trabajo').select('estado');
    final list = response as List;
    int enProceso = list.where((o) => o['estado'].toString().toLowerCase() == 'en progreso' || o['estado'] == 'en_progreso').length;
    int pendientes = list.where((o) => o['estado'].toString().toLowerCase() == 'pendiente').length;
    int completadas = list.where((o) => o['estado'].toString().toLowerCase() == 'completada').length;
    return {'en_proceso': enProceso, 'pendientes': pendientes, 'completadas': completadas};
  }
}
