class Proveedor {
  final String? id;
  final String nombre;
  final String? telefono;
  final bool entregaDomicilio;
  final DateTime? createdAt;

  Proveedor({
    this.id,
    required this.nombre,
    this.telefono,
    this.entregaDomicilio = false,
    this.createdAt,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'],
      entregaDomicilio: json['entrega_domicilio'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      'entrega_domicilio': entregaDomicilio,
    };
  }
}
