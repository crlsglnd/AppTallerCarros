class Cliente {
  final String? id;
  final String nombre;
  final String? email;
  final String? telefono;
  final DateTime? createdAt;

  Cliente({
    this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.createdAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
    };
  }
}
