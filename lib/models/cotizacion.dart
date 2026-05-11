import 'package:app_taller_carros/models/cotizacion_detalle.dart';

class Cotizacion {
  final String? id;
  final String vehiculoId;
  final double costoManoObra;
  final String metodoPago;
  final double porcentajeRecargoTarjeta;
  final double totalCalculado;
  final String estado; // 'pendiente', 'aceptada', 'declinada'
  final DateTime? createdAt;
  
  // Lista de detalles opcional
  final List<CotizacionDetalle>? detalles;

  Cotizacion({
    this.id,
    required this.vehiculoId,
    this.costoManoObra = 0.0,
    this.metodoPago = 'efectivo',
    this.porcentajeRecargoTarjeta = 0.0,
    this.totalCalculado = 0.0,
    this.estado = 'pendiente',
    this.createdAt,
    this.detalles,
  });

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    return Cotizacion(
      id: json['id'],
      vehiculoId: json['vehiculo_id'] ?? '',
      costoManoObra: (json['costo_mano_obra'] ?? 0).toDouble(),
      metodoPago: json['metodo_pago'] ?? 'efectivo',
      porcentajeRecargoTarjeta: (json['porcentaje_recargo_tarjeta'] ?? 0).toDouble(),
      totalCalculado: (json['total_calculado'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'pendiente',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
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
