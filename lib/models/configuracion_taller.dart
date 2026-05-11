class ConfiguracionTaller {
  final String? id;
  final String diaSemana;
  final int maxIngresosDiarios;
  final String horaApertura;
  final String horaCierre;
  final bool estaAbierto;
  final DateTime? updatedAt;

  ConfiguracionTaller({
    this.id,
    required this.diaSemana,
    this.maxIngresosDiarios = 5,
    this.horaApertura = '08:00',
    this.horaCierre = '17:00',
    this.estaAbierto = true,
    this.updatedAt,
  });

  factory ConfiguracionTaller.fromJson(Map<String, dynamic> json) {
    return ConfiguracionTaller(
      id: json['id'],
      diaSemana: json['dia_semana'] ?? '',
      maxIngresosDiarios: json['max_ingresos_diarios'] ?? 5,
      horaApertura: json['hora_apertura'] ?? '08:00',
      horaCierre: json['hora_cierre'] ?? '17:00',
      estaAbierto: json['esta_abierto'] ?? true,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia_semana': diaSemana,
      'max_ingresos_diarios': maxIngresosDiarios,
      'hora_apertura': horaApertura,
      'hora_cierre': horaCierre,
      'esta_abierto': estaAbierto,
    };
  }
}
