import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/evento.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<void> mostrarNotificacionRegistro(Evento evento, String nombreUsuario) async {
    try {
      await initialize();
      const androidDetails = AndroidNotificationDetails(
        'registro_eventos', 'Registro de Eventos',
        channelDescription: 'Notificaciones de registro en eventos',
        importance: Importance.high, priority: Priority.high);
      const notificationDetails = NotificationDetails(android: androidDetails);
      await _notifications.show(evento.id ?? 0, ' Registro Exitoso',
        '$nombreUsuario registrado en: ${evento.nombre}', notificationDetails);
    } catch (e) {
      // Ignorar errores de notificaciones para que no rompan la app
      print('Error en notificación: $e');
    }
  }

  Future<void> mostrarNotificacionCapacidad(Evento evento, int asistentesActuales) async {
    try {
      await initialize();
      final porcentaje = ((asistentesActuales / evento.capacidadMaxima) * 100).round();
      if (porcentaje < 75) return;
      String mensaje = porcentaje >= 90 
        ? ' Capacidad al $porcentaje% - Solo ${evento.capacidadMaxima - asistentesActuales} cupos'
        : ' Capacidad al $porcentaje% - ${evento.capacidadMaxima - asistentesActuales} cupos restantes';
      const androidDetails = AndroidNotificationDetails(
        'capacidad_eventos', 'Capacidad de Eventos',
        channelDescription: 'Alertas de capacidad de eventos',
        importance: Importance.high, priority: Priority.high);
      const notificationDetails = NotificationDetails(android: androidDetails);
      await _notifications.show((evento.id ?? 0) + 1000, ' Alerta de Capacidad', mensaje, notificationDetails);
    } catch (e) {
      print('Error en notificación de capacidad: $e');
    }
  }
}
