class Repuesto {
  final String? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final int? stockMinimo;
  final DateTime? createdAt;

  Repuesto({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.stockMinimo,
    this.createdAt,
  });

  bool get stockBajo => stockMinimo != null && stock <= stockMinimo!;

  factory Repuesto.fromJson(Map<String, dynamic> json) {
    return Repuesto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: (json['precio'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      stockMinimo: json['stock_minimo'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'stock_minimo': stockMinimo,
    };
  }
}
