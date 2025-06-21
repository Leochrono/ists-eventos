class Evento {
  final int? id;
  final String nombre;
  final String descripcion;
  final DateTime fecha;
  final String ubicacion;
  final String organizador;
  final int capacidadMaxima;
  final String? imagenUrl;
  final DateTime fechaCreacion;
  final bool activo;

  Evento({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.ubicacion,
    required this.organizador,
    required this.capacidadMaxima,
    this.imagenUrl,
    DateTime? fechaCreacion,
    this.activo = true,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha': fecha.millisecondsSinceEpoch,
      'ubicacion': ubicacion,
      'organizador': organizador,
      'capacidad_maxima': capacidadMaxima,
      'imagen_url': imagenUrl,
      'fecha_creacion': fechaCreacion.millisecondsSinceEpoch,
      'activo': activo ? 1 : 0,
    };
  }

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha']),
      ubicacion: map['ubicacion'],
      organizador: map['organizador'],
      capacidadMaxima: map['capacidad_maxima'],
      imagenUrl: map['imagen_url'],
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fecha_creacion']),
      activo: map['activo'] == 1,
    );
  }

  String get codigoQR {
    const baseUrl = 'https://ists-eventos-demo.netlify.app/registro.html';
    
    final params = {
      'id': id.toString(),
      'name': nombre,
      'location': ubicacion,
      'fecha': _formatearFecha(),
      'organizador': organizador,
      'action': 'register'
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }
  
  String get codigoInterno => 'ISTS_EVENT_${id}_${nombre.replaceAll(' ', '_').toUpperCase()}';

  String _formatearFecha() {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Evento copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fecha,
    String? ubicacion,
    String? organizador,
    int? capacidadMaxima,
    String? imagenUrl,
    DateTime? fechaCreacion,
    bool? activo,
  }) {
    return Evento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      ubicacion: ubicacion ?? this.ubicacion,
      organizador: organizador ?? this.organizador,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
    );
  }
}