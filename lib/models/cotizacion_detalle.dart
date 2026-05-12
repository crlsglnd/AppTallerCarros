class CotizacionDetalle {
  final String? id;
  final String? cotizacionId;
  final String nombre;
  final double costo;

  CotizacionDetalle({
    this.id,
    this.cotizacionId,
    required this.nombre,
    required this.costo,
  });

  factory CotizacionDetalle.fromJson(Map<String, dynamic> json) {
    return CotizacionDetalle(
      id: json['id'],
      cotizacionId: json['cotizacion_id'],
      nombre: json['nombre'] ?? json['descripcion'] ?? '', // Fallback para retrocompatibilidad
      costo: (json['costo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cotizacionId != null) 'cotizacion_id': cotizacionId,
      'nombre': nombre,
      'costo': costo,
    };
  }
}
