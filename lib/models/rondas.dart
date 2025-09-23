class Ronda {
  final int id;
  final String nombre;
  final String? horaInicio;
  final String? horaFin;
  final bool? disponible;
  final String? turnoNombre;
  final String? statusNombre;
  final int statusRondaId;

  Ronda({
    required this.id,
    required this.nombre,
    this.horaInicio,
    this.horaFin,
    this.disponible,
    this.turnoNombre,
    this.statusNombre,
    required this.statusRondaId,
  });

  factory Ronda.fromJson(Map<String, dynamic> json) {
    return Ronda(
      id: json['catalogo_ronda_id'] as int,
      nombre: json['catalogo_ronda_nombre'] as String,
      horaInicio: json['ronda_ejecutada_hora_inicio'] as String?,
      horaFin: json['ronda_ejecutada_hora_fin'] as String?,
      disponible: json['ronda_ejecutada_disponible'] as bool?,
      turnoNombre: json['turno_nombre'] as String?,
      statusNombre: json['status_nombre'] as String?,
      statusRondaId: json['status_ronda_id'] as int,
    );
  }
}
