class CotizacionDetalle {
  final String? id;
  final String cotizacionId;
  final String descripcion;
  final double costo;

  CotizacionDetalle({
    this.id,
    required this.cotizacionId,
    required this.descripcion,
    required this.costo,
  });

  factory CotizacionDetalle.fromJson(Map<String, dynamic> json) {
    return CotizacionDetalle(
      id: json['id'],
      cotizacionId: json['cotizacion_id'] ?? '',
      descripcion: json['descripcion'] ?? '',
      costo: (json['costo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cotizacion_id': cotizacionId,
      'descripcion': descripcion,
      'costo': costo,
    };
  }
}
