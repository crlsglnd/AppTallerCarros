class RepuestoReferencia {
  final String? id;
  final String nombre;
  final String marcaAplicable;
  final String modeloAplicable;
  final String aniosAplicables;
  final double precioReferencia;
  final DateTime? createdAt;

  RepuestoReferencia({
    this.id,
    required this.nombre,
    required this.marcaAplicable,
    required this.modeloAplicable,
    required this.aniosAplicables,
    this.precioReferencia = 0.0,
    this.createdAt,
  });

  factory RepuestoReferencia.fromJson(Map<String, dynamic> json) {
    return RepuestoReferencia(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      marcaAplicable: json['marca_aplicable'] ?? '',
      modeloAplicable: json['modelo_aplicable'] ?? '',
      aniosAplicables: json['anios_aplicables'] ?? '',
      precioReferencia: (json['precio_referencia'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'marca_aplicable': marcaAplicable,
      'modelo_aplicable': modeloAplicable,
      'anios_aplicables': aniosAplicables,
      'precio_referencia': precioReferencia,
    };
  }
}
