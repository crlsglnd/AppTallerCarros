import 'package:app_taller_carros/models/cotizacion_detalle.dart';

class Cotizacion {
  final String? id;
  final String vehiculoId;
  final double costoManoObra;
  final String metodoPago;
  final double porcentajeRecargoTarjeta;
  final double totalCalculado; // Cambiado de totalBase para coincidir con DB
  final String estado; // 'Pendiente', 'Aceptada', 'Declinada'
  final DateTime? createdAt;
  final List<CotizacionDetalle>? detalles;

  Cotizacion({
    this.id,
    required this.vehiculoId,
    this.costoManoObra = 0.0,
    this.metodoPago = 'Efectivo',
    this.porcentajeRecargoTarjeta = 0.0,
    required this.totalCalculado,
    this.estado = 'Pendiente',
    this.createdAt,
    this.detalles,
  });

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    var detallesList = json['cotizacion_detalles'] as List?;
    List<CotizacionDetalle>? detalles;
    if (detallesList != null) {
      detalles = detallesList.map((d) => CotizacionDetalle.fromJson(d)).toList();
    }

    return Cotizacion(
      id: json['id'],
      vehiculoId: json['vehiculo_id'] ?? '',
      costoManoObra: (json['costo_mano_obra'] ?? 0).toDouble(),
      metodoPago: json['metodo_pago'] ?? 'Efectivo',
      porcentajeRecargoTarjeta: (json['porcentaje_recargo_tarjeta'] ?? 0).toDouble(),
      totalCalculado: (json['total_calculado'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'Pendiente',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      detalles: detalles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculo_id': vehiculoId,
      'costo_mano_obra': costoManoObra,
      'metodo_pago': metodoPago,
      'porcentaje_recargo_tarjeta': porcentajeRecargoTarjeta,
      'total_calculado': totalCalculado,
      'estado': estado,
    };
  }
}
