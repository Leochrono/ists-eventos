import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../models/asistencia.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  
  final List<Evento> _eventosMemoria = [];
  final List<Usuario> _usuariosMemoria = [];
  final List<Asistencia> _asistenciasMemoria = [];
  int _nextEventoId = 1;
  int _nextUsuarioId = 1;
  int _nextAsistenciaId = 1;

  Future<Database?> get database async {
    if (kIsWeb) {
      return null;
    }
    
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Database not supported on web');
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    String path = join(await getDatabasesPath(), 'ists_eventos.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE eventos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            fecha INTEGER NOT NULL,
            ubicacion TEXT NOT NULL,
            organizador TEXT NOT NULL,
            capacidad_maxima INTEGER NOT NULL,
            imagen_url TEXT,
            fecha_creacion INTEGER NOT NULL,
            activo INTEGER NOT NULL DEFAULT 1
          )''',
        );
        
        await db.execute(
          '''CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cedula TEXT NOT NULL UNIQUE,
            nombres TEXT NOT NULL,
            apellidos TEXT NOT NULL,
            email TEXT NOT NULL,
            telefono TEXT NOT NULL,
            tipo_usuario INTEGER NOT NULL,
            fecha_registro INTEGER NOT NULL,
            carrera TEXT,
            ciclo TEXT,
            departamento TEXT,
            cargo TEXT,
            institucion TEXT,
            motivo TEXT
          )''',
        );
        
        await db.execute(
          '''CREATE TABLE asistencia(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            evento_id INTEGER NOT NULL,
            usuario_id INTEGER NOT NULL,
            fecha_registro INTEGER NOT NULL,
            presente INTEGER NOT NULL DEFAULT 1,
            observaciones TEXT,
            FOREIGN KEY (evento_id) REFERENCES eventos (id),
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
            UNIQUE(evento_id, usuario_id)
          )''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            '''CREATE TABLE IF NOT EXISTS usuarios(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cedula TEXT NOT NULL UNIQUE,
              nombres TEXT NOT NULL,
              apellidos TEXT NOT NULL,
              email TEXT NOT NULL,
              telefono TEXT NOT NULL,
              tipo_usuario INTEGER NOT NULL,
              fecha_registro INTEGER NOT NULL,
              carrera TEXT,
              ciclo TEXT,
              departamento TEXT,
              cargo TEXT,
              institucion TEXT,
              motivo TEXT
            )''',
          );
          
          await db.execute(
            '''CREATE TABLE IF NOT EXISTS asistencia(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              evento_id INTEGER NOT NULL,
              usuario_id INTEGER NOT NULL,
              fecha_registro INTEGER NOT NULL,
              presente INTEGER NOT NULL DEFAULT 1,
              observaciones TEXT,
              FOREIGN KEY (evento_id) REFERENCES eventos (id),
              FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
              UNIQUE(evento_id, usuario_id)
            )''',
          );
        }
      },
    );
  }

  Future<int> insertEvento(Evento evento) async {
    if (kIsWeb) {
      final nuevoEvento = evento.copyWith(id: _nextEventoId++);
      _eventosMemoria.add(nuevoEvento);
      return nuevoEvento.id!;
    }
    
    final db = await database;
    return await db!.insert('eventos', evento.toMap());
  }

  Future<List<Evento>> getEventos() async {
    if (kIsWeb) {
      return _eventosMemoria.where((e) => e.activo).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'eventos',
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) {
      return Evento.fromMap(maps[i]);
    });
  }

  Future<Evento?> getEvento(int id) async {
    if (kIsWeb) {
      try {
        return _eventosMemoria.firstWhere((e) => e.id == id && e.activo);
      } catch (e) {
        return null;
      }
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'eventos',
      where: 'id = ? AND activo = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return Evento.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEvento(Evento evento) async {
    if (kIsWeb) {
      final index = _eventosMemoria.indexWhere((e) => e.id == evento.id);
      if (index != -1) {
        _eventosMemoria[index] = evento;
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db!.update(
      'eventos',
      evento.toMap(),
      where: 'id = ?',
      whereArgs: [evento.id],
    );
  }

  Future<int> deleteEvento(int id) async {
    if (kIsWeb) {
      final index = _eventosMemoria.indexWhere((e) => e.id == id);
      if (index != -1) {
        _eventosMemoria[index] = _eventosMemoria[index].copyWith(activo: false);
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db!.update(
      'eventos',
      {'activo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Evento>> searchEventos(String query) async {
    if (kIsWeb) {
      return _eventosMemoria.where((evento) =>
        evento.activo &&
        (evento.nombre.toLowerCase().contains(query.toLowerCase()) ||
         evento.descripcion.toLowerCase().contains(query.toLowerCase()) ||
         evento.organizador.toLowerCase().contains(query.toLowerCase()))
      ).toList()..sort((a, b) => b.fecha.compareTo(a.fecha));
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'eventos',
      where: 'activo = ? AND (nombre LIKE ? OR descripcion LIKE ? OR organizador LIKE ?)',
      whereArgs: [1, '%$query%', '%$query%', '%$query%'],
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) {
      return Evento.fromMap(maps[i]);
    });
  }

  Future<int> insertUsuario(Usuario usuario) async {
    if (kIsWeb) {
      final nuevoUsuario = usuario.copyWith(id: _nextUsuarioId++);
      _usuariosMemoria.add(nuevoUsuario);
      return nuevoUsuario.id!;
    }
    
    final db = await database;
    return await db!.insert('usuarios', usuario.toMap());
  }

  Future<Usuario?> getUsuarioPorCedula(String cedula) async {
    if (kIsWeb) {
      try {
        return _usuariosMemoria.firstWhere((u) => u.cedula == cedula);
      } catch (e) {
        return null;
      }
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'usuarios',
      where: 'cedula = ?',
      whereArgs: [cedula],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Usuario>> getUsuarios() async {
    if (kIsWeb) {
      return List.from(_usuariosMemoria)
        ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'usuarios',
      orderBy: 'fecha_registro DESC',
    );

    return List.generate(maps.length, (i) {
      return Usuario.fromMap(maps[i]);
    });
  }

  Future<int> updateUsuario(Usuario usuario) async {
    if (kIsWeb) {
      final index = _usuariosMemoria.indexWhere((u) => u.id == usuario.id);
      if (index != -1) {
        _usuariosMemoria[index] = usuario;
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db!.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> registrarAsistencia(Asistencia asistencia) async {
    if (kIsWeb) {
      final yaExiste = _asistenciasMemoria.any((a) => 
        a.eventoId == asistencia.eventoId && a.usuarioId == asistencia.usuarioId);
      
      if (yaExiste) {
        throw Exception('Usuario ya registrado en este evento');
      }
      
      final nuevaAsistencia = asistencia.copyWith(id: _nextAsistenciaId++);
      _asistenciasMemoria.add(nuevaAsistencia);
      return nuevaAsistencia.id!;
    }
    
    final db = await database;
    return await db!.insert(
      'asistencia', 
      asistencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> yaRegistradoEnEvento(int eventoId, int usuarioId) async {
    if (kIsWeb) {
      return _asistenciasMemoria.any((a) => 
        a.eventoId == eventoId && a.usuarioId == usuarioId);
    }
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'asistencia',
      where: 'evento_id = ? AND usuario_id = ?',
      whereArgs: [eventoId, usuarioId],
    );

    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAsistenciaEvento(int eventoId) async {
    if (kIsWeb) {
      final asistenciasEvento = _asistenciasMemoria
        .where((a) => a.eventoId == eventoId)
        .toList();
      
      return asistenciasEvento.map((asistencia) {
        final usuario = _usuariosMemoria.firstWhere((u) => u.id == asistencia.usuarioId);
        final map = usuario.toMap();
        map['fecha_asistencia'] = asistencia.fechaRegistro.millisecondsSinceEpoch;
        map['observaciones'] = asistencia.observaciones;
        return map;
      }).toList()..sort((a, b) => b['fecha_asistencia'].compareTo(a['fecha_asistencia']));
    }
    
    final db = await database;
    return await db!.rawQuery('''
      SELECT u.*, a.fecha_registro as fecha_asistencia, a.observaciones
      FROM usuarios u
      INNER JOIN asistencia a ON u.id = a.usuario_id
      WHERE a.evento_id = ?
      ORDER BY a.fecha_registro DESC
    ''', [eventoId]);
  }

  Future<int> getCountAsistencia(int eventoId) async {
    if (kIsWeb) {
      return _asistenciasMemoria.where((a) => a.eventoId == eventoId).length;
    }
    
    final db = await database;
    final result = await db!.rawQuery(
      'SELECT COUNT(*) as count FROM asistencia WHERE evento_id = ?',
      [eventoId],
    );
    return result.first['count'] as int;
  }

  Future<void> cargarDatosPrueba() async {
    if (kIsWeb && _eventosMemoria.isEmpty) {
      final eventoPrueba = Evento(
        id: 1,
        nombre: 'Conferencia de Tecnología 2025',
        descripcion: 'Conferencia sobre las últimas tendencias en tecnología y desarrollo de software.',
        fecha: DateTime.now().add(const Duration(days: 7)),
        ubicacion: 'Auditorio Principal ISTS',
        organizador: 'Carrera de Desarrollo de Software',
        capacidadMaxima: 100,
        fechaCreacion: DateTime.now(),
        activo: true,
      );
      
      _eventosMemoria.add(eventoPrueba);
      _nextEventoId = 2;
    }
  }
}