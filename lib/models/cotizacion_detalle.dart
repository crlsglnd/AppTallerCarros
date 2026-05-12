class CotizacionDetalle {
  final String? id;
  final String? cotizacionId;
  final String descripcion; // Cambiado de nombre para coincidir con DB
  final double costo;

  CotizacionDetalle({
    this.id,
    this.cotizacionId,
    required this.descripcion,
    required this.costo,
  });

  factory CotizacionDetalle.fromJson(Map<String, dynamic> json) {
    return CotizacionDetalle(
      id: json['id'],
      cotizacionId: json['cotizacion_id'],
      descripcion: json['descripcion'] ?? json['nombre'] ?? '', // Fallback
      costo: (json['costo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cotizacionId != null) 'cotizacion_id': cotizacionId,
      'descripcion': descripcion,
      'costo': costo,
    };
  }
}
