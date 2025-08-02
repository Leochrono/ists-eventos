// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/evento.dart';
import '../models/usuario.dart';
import '../models/usuario_api.dart';
import '../models/asistencia.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _authService.getToken();
    if (token != null) {
      return ApiConfig.authHeaders(token);
    }
    return ApiConfig.defaultHeaders;
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      case 401:
        throw AuthException('No autorizado');
      case 403:
        throw AuthException('Acceso denegado');
      case 404:
        throw ApiException('Recurso no encontrado');
      case 400:
        throw ApiException('Datos inválidos');
      case 500:
        throw ServerException('Error del servidor', 500);
      default:
        throw ApiException('Error HTTP ${response.statusCode}');
    }
  }

  Future<T> _safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on HttpException {
      throw NetworkException('Error de conexión');
    } on FormatException {
      throw ApiException('Respuesta inválida del servidor');
    }
  }

  // ============================================================================
  // AUTENTICACIÓN
  // ============================================================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _safeRequest(() async {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.token}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      return _handleResponse(response);
    });
  }

  // ============================================================================
  // EVENTOS
  // ============================================================================

  Future<List<Evento>> getEventos() async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventos}'),
        headers: headers,
      );
      
      final data = _handleResponse(response) as List;
      return data.map((json) => Evento.fromApiJson(json)).toList();
    });
  }

  Future<Evento> createEvento(Evento evento) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventos}'),
        headers: headers,
        body: json.encode(evento.toApiJson()),
      );
      
      final data = _handleResponse(response);
      return Evento.fromApiJson(data);
    });
  }

  Future<Evento?> getEvento(int id) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventos}$id/'),
        headers: headers,
      );
      
      final data = _handleResponse(response);
      return data != null ? Evento.fromApiJson(data) : null;
    });
  }

  Future<Evento> updateEvento(Evento evento) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventos}${evento.id}/'),
        headers: headers,
        body: json.encode(evento.toApiJson()),
      );
      
      final data = _handleResponse(response);
      return Evento.fromApiJson(data);
    });
  }

  Future<void> deleteEvento(int id) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventos}$id/'),
        headers: headers,
      );
      
      _handleResponse(response);
    });
  }

  Future<List<Evento>> searchEventos(String query) async {
    // La API no tiene endpoint de búsqueda, filtrar localmente
    final eventos = await getEventos();
    return eventos.where((evento) =>
      evento.nombre.toLowerCase().contains(query.toLowerCase()) ||
      evento.descripcion.toLowerCase().contains(query.toLowerCase()) ||
      evento.organizador.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // ============================================================================
  // USUARIOS
  // ============================================================================

  Future<Usuario?> getUsuarioPorCedula(String cedula) async {
    try {
      final usuarioApi = await consultarUsuario(cedula, 'EST'); // Probar como estudiante primero
      if (usuarioApi != null) {
        // Convertir UsuarioApi a Usuario (crear método en Usuario si no existe)
        return Usuario(
          cedula: usuarioApi.cedula,
          nombres: usuarioApi.nombre?.split(' ').first ?? '',
          apellidos: usuarioApi.nombre?.split(' ').skip(1).join(' ') ?? '',
          email: usuarioApi.email ?? '',
          telefono: '',
          tipoUsuario: _stringToTipoUsuario(usuarioApi.tipoUsuario),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  TipoUsuario _stringToTipoUsuario(String tipo) {
    switch (tipo) {
      case 'EST': return TipoUsuario.estudiante;
      case 'PRO': return TipoUsuario.docente;
      case 'ADM': return TipoUsuario.administrativo;
      case 'EXT': return TipoUsuario.invitado;
      default: return TipoUsuario.estudiante;
    }
  }

  // ============================================================================
  // ASISTENCIA
  // ============================================================================

  Future<int> registrarAsistencia(Asistencia asistencia) async {
    return _safeRequest(() async {
      await registrarEvento(asistencia.usuarioId.toString(), asistencia.eventoId);
      return asistencia.id ?? 1;
    });
  }

  Future<bool> yaRegistradoEnEvento(int eventoId, int usuarioId) async {
    try {
      final asistencias = await getAsistenciaEvento(eventoId);
      return asistencias.any((a) => a['usuario_id'] == usuarioId);
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAsistenciaEvento(int eventoId) async {
    // Simular datos de asistencia ya que la API no tiene este endpoint específico
    return [];
  }

  Future<int> getCountAsistencia(int eventoId) async {
    final asistencias = await getAsistenciaEvento(eventoId);
    return asistencias.length;
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS DE LA API
  // ============================================================================

  Future<List<Map<String, dynamic>>> getCarreras() async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carreras}'),
        headers: headers,
      );
      
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    });
  }

  Future<List<Map<String, dynamic>>> getTiposEvento() async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tiposEvento}'),
        headers: headers,
      );
      
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    });
  }

  Future<List<Map<String, dynamic>>> getSecciones() async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.secciones}'),
        headers: headers,
      );
      
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    });
  }

  Future<UsuarioApi?> consultarUsuario(String cedula, String tipoUsuario) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.consultarUsuario}'),
        headers: headers,
        body: json.encode({
          'cedula': cedula,
          'tipo_usuario': tipoUsuario,
        }),
      );
      
      final data = _handleResponse(response);
      return data != null ? UsuarioApi.fromJson(data) : null;
    });
  }

  Future<void> registrarEvento(String usuarioId, int eventoId) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registrarEvento}'),
        headers: headers,
        body: json.encode({
          'usuario_id': usuarioId,
          'evento_id': eventoId,
        }),
      );
      
      _handleResponse(response);
    });
  }

  Future<void> seleccionarSecciones(String registroId, List<int> secciones) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.seleccionarSecciones}'),
        headers: headers,
        body: json.encode({
          'registro_id': registroId,
          'secciones': secciones,
        }),
      );
      
      _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> scanQR(String token) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scan}'),
        headers: headers,
        body: json.encode({
          'token': token,
        }),
      );
      
      return _handleResponse(response);
    });
  }

  Future<List<Map<String, dynamic>>> getReporte(int eventoId) async {
    return _safeRequest(() async {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.report}$eventoId/'),
        headers: headers,
      );
      
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    });
  }
}
