class Usuario {
  final int? id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final TipoUsuario tipoUsuario;
  final DateTime fechaRegistro;
  
  final String? carrera;        
  final String? ciclo;          
  final String? departamento;   
  final String? cargo;          
  final String? institucion;    
  final String? motivo;         

  Usuario({
    this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.tipoUsuario,
    DateTime? fechaRegistro,
    this.carrera,
    this.ciclo,
    this.departamento,
    this.cargo,
    this.institucion,
    this.motivo,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'tipo_usuario': tipoUsuario.index,
      'fecha_registro': fechaRegistro.millisecondsSinceEpoch,
      'carrera': carrera,
      'ciclo': ciclo,
      'departamento': departamento,
      'cargo': cargo,
      'institucion': institucion,
      'motivo': motivo,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      cedula: map['cedula'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      email: map['email'],
      telefono: map['telefono'],
      tipoUsuario: TipoUsuario.values[map['tipo_usuario']],
      fechaRegistro: DateTime.fromMillisecondsSinceEpoch(map['fecha_registro']),
      carrera: map['carrera'],
      ciclo: map['ciclo'],
      departamento: map['departamento'],
      cargo: map['cargo'],
      institucion: map['institucion'],
      motivo: map['motivo'],
    );
  }

  String get nombreCompleto => '$nombres $apellidos';
  
  String get tipoTexto {
    switch (tipoUsuario) {
      case TipoUsuario.estudiante:
        return 'Estudiante';
      case TipoUsuario.docente:
        return 'Docente';
      case TipoUsuario.administrativo:
        return 'Administrativo';
      case TipoUsuario.invitado:
        return 'Invitado';
    }
  }

  Usuario copyWith({
    int? id,
    String? cedula,
    String? nombres,
    String? apellidos,
    String? email,
    String? telefono,
    TipoUsuario? tipoUsuario,
    DateTime? fechaRegistro,
    String? carrera,
    String? ciclo,
    String? departamento,
    String? cargo,
    String? institucion,
    String? motivo,
  }) {
    return Usuario(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      carrera: carrera ?? this.carrera,
      ciclo: ciclo ?? this.ciclo,
      departamento: departamento ?? this.departamento,
      cargo: cargo ?? this.cargo,
      institucion: institucion ?? this.institucion,
      motivo: motivo ?? this.motivo,
    );
  }
}

enum TipoUsuario {
  estudiante,
  docente,
  administrativo,
  invitado,
}

class CarrerasISTS {
  static const List<String> carreras = [
    'Desarrollo de Software',
    'Administración',
    'Marketing',
    'Gastronomía',
    'Protección del Medio Ambiente',
    'Diseño Gráfico',
    'Contabilidad',
    'Turismo',
    'Mecánica Automotriz',
    'Electricidad',
  ];
  
  static const List<String> ciclos = [
    'Primer Ciclo',
    'Segundo Ciclo',
    'Tercer Ciclo',
    'Cuarto Ciclo',
    'Quinto Ciclo',
    'Sexto Ciclo',
  ];
  
  static const List<String> departamentos = [
    'Rectorado',
    'Vicerrectorado',
    'Dirección Académica',
    'Secretaría General',
    'Bienestar Estudiantil',
    'Sistemas',
    'Biblioteca',
    'Mantenimiento',
    'Contabilidad',
    'Talento Humano',
  ];
}
