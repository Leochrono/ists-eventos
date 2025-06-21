class Asistencia {
  final int? id;
  final int eventoId;
  final int usuarioId;
  final DateTime fechaRegistro;
  final bool presente;
  final String? observaciones;

  Asistencia({
    this.id,
    required this.eventoId,
    required this.usuarioId,
    DateTime? fechaRegistro,
    this.presente = true,
    this.observaciones,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'usuario_id': usuarioId,
      'fecha_registro': fechaRegistro.millisecondsSinceEpoch,
      'presente': presente ? 1 : 0,
      'observaciones': observaciones,
    };
  }

  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      id: map['id'],
      eventoId: map['evento_id'],
      usuarioId: map['usuario_id'],
      fechaRegistro: DateTime.fromMillisecondsSinceEpoch(map['fecha_registro']),
      presente: map['presente'] == 1,
      observaciones: map['observaciones'],
    );
  }

  Asistencia copyWith({
    int? id,
    int? eventoId,
    int? usuarioId,
    DateTime? fechaRegistro,
    bool? presente,
    String? observaciones,
  }) {
    return Asistencia(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      presente: presente ?? this.presente,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}