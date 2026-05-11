class Vehiculo {
  final String? id;
  final String clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final int? anio;
  final String? color;
  final DateTime? createdAt;

  Vehiculo({
    this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placa,
    this.anio,
    this.color,
    this.createdAt,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      clienteId: json['cliente_id'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placa: json['placa'] ?? '',
      anio: json['anio'],
      color: json['color'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
      'anio': anio,
      'color': color,
    };
  }
}
