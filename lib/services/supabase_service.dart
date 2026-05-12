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

  // VEHICULOS
  Future<List<Vehiculo>> getVehiculos() async {
    final response = await _client.from('vehiculos').select().order('placa');
    return (response as List).map((json) => Vehiculo.fromJson(json)).toList();
  }

  Future<void> insertVehiculo(Vehiculo vehiculo) async {
    await _client.from('vehiculos').insert(vehiculo.toJson());
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

  // ORDENES
  Future<List<OrdenTrabajo>> getOrdenes() async {
    final response = await _client.from('ordenes_trabajo').select().order('fecha_ingreso', ascending: false);
    return (response as List).map((json) => OrdenTrabajo.fromJson(json)).toList();
  }

  Future<void> insertOrden(OrdenTrabajo orden) async {
    await _client.from('ordenes_trabajo').insert(orden.toJson());
  }

  // PROVEEDORES
  Future<List<Proveedor>> getProveedores() async {
    final response = await _client.from('proveedores').select().order('nombre');
    return (response as List).map((json) => Proveedor.fromJson(json)).toList();
  }

  Future<void> insertProveedor(Proveedor proveedor) async {
    await _client.from('proveedores').insert(proveedor.toJson());
  }

  // REPUESTOS REFERENCIA
  Future<List<RepuestoReferencia>> getRepuestosReferencia() async {
    final response = await _client.from('repuestos_referencia').select().order('nombre');
    return (response as List).map((json) => RepuestoReferencia.fromJson(json)).toList();
  }

  Future<void> insertRepuestoReferencia(RepuestoReferencia repuesto) async {
    await _client.from('repuestos_referencia').insert(repuesto.toJson());
  }

  // CONFIGURACION
  Future<List<ConfiguracionTaller>> getConfiguracion() async {
    final response = await _client.from('configuracion_taller').select().order('dia_semana');
    return (response as List).map((json) => ConfiguracionTaller.fromJson(json)).toList();
  }

  Future<void> updateConfiguracionDia(ConfiguracionTaller config) async {
    await _client.from('configuracion_taller').update(config.toJson()).eq('dia_semana', config.diaSemana);
  }
}
