class OrdenTrabajo {
  final String? id;
  final String vehiculoId;
  final String descripcion;
  final String estado; // 'pendiente', 'en_progreso', 'completada'
  final DateTime? fechaIngreso;
  final DateTime? fechaEntrega;
  final DateTime? createdAt;

  OrdenTrabajo({
    this.id,
    required this.vehiculoId,
    required this.descripcion,
    this.estado = 'pendiente',
    this.fechaIngreso,
    this.fechaEntrega,
    this.createdAt,
  });

  factory OrdenTrabajo.fromJson(Map<String, dynamic> json) {
    return OrdenTrabajo(
      id: json['id'],
      vehiculoId: json['vehiculo_id'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      fechaIngreso: json['fecha_ingreso'] != null
          ? DateTime.parse(json['fecha_ingreso'])
          : null,
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.parse(json['fecha_entrega'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
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
