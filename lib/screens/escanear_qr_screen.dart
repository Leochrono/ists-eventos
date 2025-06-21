import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/evento.dart';
import '../services/database_service.dart';
import 'detalle_evento_screen.dart';
import 'seleccion_tipo_usuario_screen.dart';

class EscanearQRScreen extends StatefulWidget {
  const EscanearQRScreen({super.key});

  @override
  State<EscanearQRScreen> createState() => _EscanearQRScreenState();
}

class _EscanearQRScreenState extends State<EscanearQRScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de cámara requerido para escanear QR'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            child: const Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(height: 8),
                Text(
                  'Escanea el QR del evento para registrar tu asistencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'El escaneo se realizará automáticamente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (BarcodeCapture capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && !isProcessing) {
                      final barcode = barcodes.first;
                      if (barcode.rawValue != null) {
                        _procesarCodigoQR(barcode.rawValue!);
                      }
                    }
                  },
                ),
                if (isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Procesando código QR...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Proceso de Registro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Escanea el código QR del evento\n'
                          '2. Selecciona tu tipo de usuario\n'
                          '3. Completa tus datos personales\n'
                          '4. Confirma tu registro de asistencia',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarCodigoQR(String codigo) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
    });

    try {
      await controller.stop();

      if (codigo.startsWith('ISTS_EVENT_')) {
        await _procesarEventoQR(codigo);
      } else if (codigo.startsWith('https://ists-eventos-web.vercel.app')) {
        await _procesarUrlWeb(codigo);
      } else {
        await _mostrarInformacionQR(codigo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await controller.start();
      }
    }
  }

  Future<void> _procesarEventoQR(String codigo) async {
    try {

      final partes = codigo.split('_');
      if (partes.length >= 3) {
        final eventoId = int.tryParse(partes[2]);
        if (eventoId != null) {
          final evento = await _databaseService.getEvento(eventoId);
          if (evento != null) {
            if (mounted) {
              _mostrarOpcionesEvento(evento);
            }
            return;
          }
        }
      }
      
      if (mounted) {
        _mostrarDialogoError('Evento no encontrado', 
          'El código QR escaneado no corresponde a un evento registrado en esta aplicación.');
      }
    } catch (e) {
      if (mounted) {
        _mostrarDialogoError('Error', 'Error al procesar el código QR del evento: $e');
      }
    }
  }

  Future<void> _procesarUrlWeb(String url) async {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      
      if (params.containsKey('id')) {
        final eventoId = int.tryParse(params['id'] ?? '');
        if (eventoId != null) {
          final evento = await _databaseService.getEvento(eventoId);
          if (evento != null && mounted) {
            _mostrarOpcionesEvento(evento);
            return;
          }
        }
      }
      
      if (mounted) {
        _mostrarDialogoError('Evento no encontrado', 
          'No se pudo encontrar el evento en la base de datos local.');
      }
    } catch (e) {
      if (mounted) {
        _mostrarDialogoError('Error', 'Error al procesar la URL: $e');
      }
    }
  }

  Future<void> _mostrarOpcionesEvento(Evento evento) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.event, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text('Evento Encontrado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ubicación: ${evento.ubicacion}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Qué deseas hacer?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleEventoScreen(evento: evento),
                  ),
                );
              },
              child: const Text('Ver Detalles'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeleccionTipoUsuarioScreen(evento: evento),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Registrar Asistencia'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarInformacionQR(String codigo) async {
    if (!mounted) return;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.qr_code, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text('Código QR Escaneado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contenido del código QR:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  codigo,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nota: Este no es un código QR de evento ISTS.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(titulo),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}