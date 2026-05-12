import 'package:app_taller_carros/models/vehiculo.dart';

class OrdenTrabajo {
  final String? id;
  final String vehiculoId;
  final String descripcion;
  final String estado; // 'Pendiente', 'En Progreso', 'Completada'
  final DateTime? fechaIngreso;
  final DateTime? fechaEntrega;
  final DateTime? createdAt;
  final Vehiculo? vehiculo; // Información del vehículo anidada

  OrdenTrabajo({
    this.id,
    required this.vehiculoId,
    required this.descripcion,
    this.estado = 'Pendiente',
    this.fechaIngreso,
    this.fechaEntrega,
    this.createdAt,
    this.vehiculo,
  });

  factory OrdenTrabajo.fromJson(Map<String, dynamic> json) {
    Vehiculo? veh;
    if (json['vehiculos'] != null) {
      veh = Vehiculo.fromJson(json['vehiculos']);
    }

    return OrdenTrabajo(
      id: json['id'],
      vehiculoId: json['vehiculo_id'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
      fechaIngreso: json['fecha_ingreso'] != null ? DateTime.parse(json['fecha_ingreso']) : null,
      fechaEntrega: json['fecha_entrega'] != null ? DateTime.parse(json['fecha_entrega']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      vehiculo: veh,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculo_id': vehiculoId,
      'descripcion': descripcion,
      'estado': estado,
      'fecha_ingreso': fechaIngreso?.toIso8601String(),
      'fecha_entrega': fechaEntrega?.toIso8601String(),
    };
  }
}
