// lib/models/usuario_api.dart
import 'usuario.dart';

class UsuarioApi {
  final String cedula;
  final String tipoUsuario;
  final String? nombre;
  final String? email;

  UsuarioApi({
    required this.cedula,
    required this.tipoUsuario,
    this.nombre,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'tipo_usuario': tipoUsuario,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
    };
  }

  factory UsuarioApi.fromJson(Map<String, dynamic> json) {
    return UsuarioApi(
      cedula: json['cedula'],
      tipoUsuario: json['tipo_usuario'],
      nombre: json['nombre'],
      email: json['email'],
    );
  }
  
  factory UsuarioApi.fromUsuario(Usuario usuario) {
    String tipoApi;
    switch (usuario.tipoUsuario) {
      case TipoUsuario.estudiante:
        tipoApi = 'EST';
        break;
      case TipoUsuario.docente:
        tipoApi = 'PRO';
        break;
      case TipoUsuario.administrativo:
        tipoApi = 'ADM';
        break;
      case TipoUsuario.invitado:
        tipoApi = 'EXT';
        break;
    }
    
    return UsuarioApi(
      cedula: usuario.cedula,
      tipoUsuario: tipoApi,
      nombre: usuario.nombreCompleto,
      email: usuario.email,
    );
  }
}
