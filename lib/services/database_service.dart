// lib/services/database_service.dart
import '../models/evento.dart';
import '../models/usuario.dart';
import '../models/asistencia.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Servicio de base de datos que ahora actúa como wrapper del ApiService
/// Mantiene la misma interfaz para compatibilidad con el código existente
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final ApiService _apiService = ApiService();
  bool _useOfflineMode = false;

  // Datos offline de respaldo
  final List<Evento> _eventosOffline = [];
  final List<Usuario> _usuariosOffline = [];

  // ============================================================================
  // EVENTOS
  // ============================================================================
  
  Future<int> insertEvento(Evento evento) async {
    try {
      if (_useOfflineMode) {
        final nuevoEvento = evento.copyWith(id: _eventosOffline.length + 1);
        _eventosOffline.add(nuevoEvento);
        return nuevoEvento.id!;
      }
      
      final eventoCreado = await _apiService.createEvento(evento);
      return eventoCreado.id ?? 0;
    } catch (e) {
      // Fallback a modo offline
      _useOfflineMode = true;
      final nuevoEvento = evento.copyWith(id: _eventosOffline.length + 1);
      _eventosOffline.add(nuevoEvento);
      return nuevoEvento.id!;
    }
  }

  Future<List<Evento>> getEventos() async {
    try {
      if (_useOfflineMode) {
        return _eventosOffline;
      }
      
      return await _apiService.getEventos();
    } catch (e) {
      _useOfflineMode = true;
      return _eventosOffline;
    }
  }

  Future<Evento?> getEvento(int id) async {
    try {
      if (_useOfflineMode) {
        try {
          return _eventosOffline.firstWhere((e) => e.id == id);
        } catch (e) {
          return null;
        }
      }
      
      return await _apiService.getEvento(id);
    } catch (e) {
      _useOfflineMode = true;
      try {
        return _eventosOffline.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  Future<int> updateEvento(Evento evento) async {
    try {
      if (_useOfflineMode) {
        final index = _eventosOffline.indexWhere((e) => e.id == evento.id);
        if (index != -1) {
          _eventosOffline[index] = evento;
          return 1;
        }
        return 0;
      }
      
      await _apiService.updateEvento(evento);
      return 1;
    } catch (e) {
      _useOfflineMode = true;
      final index = _eventosOffline.indexWhere((e) => e.id == evento.id);
      if (index != -1) {
        _eventosOffline[index] = evento;
        return 1;
      }
      return 0;
    }
  }

  Future<int> deleteEvento(int id) async {
    try {
      if (_useOfflineMode) {
        _eventosOffline.removeWhere((e) => e.id == id);
        return 1;
      }
      
      await _apiService.deleteEvento(id);
      return 1;
    } catch (e) {
      _useOfflineMode = true;
      _eventosOffline.removeWhere((e) => e.id == id);
      return 1;
    }
  }

  Future<List<Evento>> searchEventos(String query) async {
    try {
      if (_useOfflineMode) {
        return _eventosOffline.where((evento) =>
          evento.nombre.toLowerCase().contains(query.toLowerCase()) ||
          evento.descripcion.toLowerCase().contains(query.toLowerCase()) ||
          evento.organizador.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      
      return await _apiService.searchEventos(query);
    } catch (e) {
      _useOfflineMode = true;
      return _eventosOffline.where((evento) =>
        evento.nombre.toLowerCase().contains(query.toLowerCase()) ||
        evento.descripcion.toLowerCase().contains(query.toLowerCase()) ||
        evento.organizador.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }

  // ============================================================================
  // USUARIOS
  // ============================================================================
  
  Future<int> insertUsuario(Usuario usuario) async {
    try {
      final nuevoUsuario = usuario.copyWith(id: _usuariosOffline.length + 1);
      _usuariosOffline.add(nuevoUsuario);
      return nuevoUsuario.id!;
    } catch (e) {
      return 1;
    }
  }

  Future<Usuario?> getUsuarioPorCedula(String cedula) async {
    try {
      if (_useOfflineMode) {
        try {
          return _usuariosOffline.firstWhere((u) => u.cedula == cedula);
        } catch (e) {
          return null;
        }
      }
      
      return await _apiService.getUsuarioPorCedula(cedula);
    } catch (e) {
      _useOfflineMode = true;
      try {
        return _usuariosOffline.firstWhere((u) => u.cedula == cedula);
      } catch (e) {
        return null;
      }
    }
  }

  Future<List<Usuario>> getUsuarios() async {
    return _usuariosOffline;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final index = _usuariosOffline.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _usuariosOffline[index] = usuario;
      return 1;
    }
    return 0;
  }

  // ============================================================================
  // ASISTENCIA
  // ============================================================================
  
  Future<int> registrarAsistencia(Asistencia asistencia) async {
    try {
      if (_useOfflineMode) {
        return 1;
      }
      
      return await _apiService.registrarAsistencia(asistencia);
    } catch (e) {
      _useOfflineMode = true;
      return 1;
    }
  }

  Future<bool> yaRegistradoEnEvento(int eventoId, int usuarioId) async {
    try {
      if (_useOfflineMode) {
        return false;
      }
      
      return await _apiService.yaRegistradoEnEvento(eventoId, usuarioId);
    } catch (e) {
      _useOfflineMode = true;
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAsistenciaEvento(int eventoId) async {
    try {
      if (_useOfflineMode) {
        return [];
      }
      
      return await _apiService.getAsistenciaEvento(eventoId);
    } catch (e) {
      _useOfflineMode = true;
      return [];
    }
  }

  Future<int> getCountAsistencia(int eventoId) async {
    try {
      if (_useOfflineMode) {
        return 0;
      }
      
      return await _apiService.getCountAsistencia(eventoId);
    } catch (e) {
      _useOfflineMode = true;
      return 0;
    }
  }

  // ============================================================================
  // MÉTODOS ESPECÍFICOS DE LA API
  // ============================================================================
  
  Future<List<Map<String, dynamic>>> getCarreras() async {
    try {
      return await _apiService.getCarreras();
    } catch (e) {
      // Retornar carreras por defecto
      return [
        {'id': 1, 'nombre': 'Desarrollo de Software'},
        {'id': 2, 'nombre': 'Administración'},
        {'id': 3, 'nombre': 'Marketing'},
        {'id': 4, 'nombre': 'Gastronomía'},
        {'id': 5, 'nombre': 'Protección del Medio Ambiente'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getTiposEvento() async {
    try {
      return await _apiService.getTiposEvento();
    } catch (e) {
      return [
        {'id': 1, 'nombre': 'Conferencia'},
        {'id': 2, 'nombre': 'Taller'},
        {'id': 3, 'nombre': 'Seminario'},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getSecciones() async {
    try {
      return await _apiService.getSecciones();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> consultarUsuario(String cedula, String tipoUsuario) async {
    try {
      final usuario = await _apiService.consultarUsuario(cedula, tipoUsuario);
      return usuario?.toJson();
    } catch (e) {
      return null;
    }
  }

  Future<String?> registrarEnEvento(String usuarioId, int eventoId) async {
    try {
      await _apiService.registrarEvento(usuarioId, eventoId);
      return 'success';
    } catch (e) {
      return null;
    }
  }

  Future<bool> seleccionarSecciones(String registroId, List<int> secciones) async {
    try {
      await _apiService.seleccionarSecciones(registroId, secciones);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> scanQR(String token) async {
    try {
      return await _apiService.scanQR(token);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getReporteEvento(int eventoId) async {
    try {
      return await _apiService.getReporte(eventoId);
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // MÉTODOS DE COMPATIBILIDAD
  // ============================================================================
  
  Future<void> initDatabase() async {
    // Intentar conectar con la API
    try {
      await _apiService.getEventos();
      _useOfflineMode = false;
    } catch (e) {
      _useOfflineMode = true;
      await cargarDatosPrueba();
    }
  }

  Future<void> cargarDatosPrueba() async {
    if (_eventosOffline.isEmpty) {
      final eventoPrueba = Evento(
        id: 1,
        nombre: 'Conferencia de Tecnología 2025',
        descripcion: 'Conferencia sobre las últimas tendencias en tecnología.',
        fecha: DateTime.now().add(const Duration(days: 7)),
        ubicacion: 'Auditorio Principal ISTS',
        organizador: 'Carrera de Desarrollo de Software',
        capacidadMaxima: 100,
        fechaCreacion: DateTime.now(),
        activo: true,
      );
      
      _eventosOffline.add(eventoPrueba);
    }
  }

  // Getter para saber si está en modo offline
  bool get isOfflineMode => _useOfflineMode;
  
  // Método para forzar modo offline
  void setOfflineMode(bool offline) {
    _useOfflineMode = offline;
  }
}
