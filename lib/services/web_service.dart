import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/evento.dart';

class WebService {
  static final WebService _instance = WebService._internal();
  factory WebService() => _instance;
  WebService._internal();

  String generarUrlRegistro(Evento evento) {
    const baseUrl = 'https://ists-eventos-web.vercel.app/registro.html';
    
    final params = {
      'id': evento.id.toString(),
      'name': evento.nombre,
      'location': evento.ubicacion,
      'fecha': _formatearFecha(evento.fecha),
      'organizador': evento.organizador,
      'action': 'register'
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  String generarUrlCompartir(Evento evento) {
    const baseUrl = 'https://ists-eventos-web.vercel.app/evento.html';
    
    final params = {
      'id': evento.id.toString(),
      'name': evento.nombre,
      'location': evento.ubicacion,
      'fecha': _formatearFecha(evento.fecha),
      'organizador': evento.organizador,
      'descripcion': evento.descripcion,
      'capacidad': evento.capacidadMaxima.toString(),
      'action': 'view'
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Future<bool> abrirRegistroWeb(Evento evento) async {
    final url = generarUrlRegistro(evento);
    return await _abrirUrl(url);
  }

  Future<bool> abrirInfoEvento(Evento evento) async {
    final url = generarUrlCompartir(evento);
    return await _abrirUrl(url);
  }

  String generarTextoCompartir(Evento evento) {
    return '''
🎓 Instituto Superior Tecnológico Sudamericano - Loja
¡Hacemos gente de talento!

📅 EVENTO: ${evento.nombre}

📝 Descripción:
${evento.descripcion}

📅 Fecha: ${_formatearFecha(evento.fecha)}
📍 Ubicación: ${evento.ubicacion}
👤 Organizador: ${evento.organizador}
👥 Capacidad: ${evento.capacidadMaxima} personas

🔗 Para registrarte escanea este QR o visita:
${generarUrlRegistro(evento)}

#ISTS #EventosEducativos #TecnológicoSudamericano #Loja #Ecuador
''';
  }

  Future<void> copiarUrlAlPortapapeles(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Future<bool> _abrirUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      return false;
    }
  }
}