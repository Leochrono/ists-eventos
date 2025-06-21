import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../screens/home_screen.dart';

class ConfirmacionRegistroScreen extends StatelessWidget {
  final Evento evento;
  final Usuario usuario;

  const ConfirmacionRegistroScreen({
    super.key,
    required this.evento,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      '¡Registro Exitoso!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Tu asistencia al evento ha sido registrada correctamente.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Evento:',
                              evento.nombre,
                              Icons.event,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildInfoRow(
                              'Fecha:',
                              DateFormat('dd/MM/yyyy HH:mm').format(evento.fecha),
                              Icons.schedule,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildInfoRow(
                              'Ubicación:',
                              evento.ubicacion,
                              Icons.location_on,
                            ),
                            
                            const Divider(height: 24),
                            
                            _buildInfoRow(
                              'Participante:',
                              usuario.nombreCompleto,
                              Icons.person,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            _buildInfoRow(
                              'Tipo:',
                              usuario.tipoTexto,
                              Icons.badge,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            if (usuario.carrera != null)
                              _buildInfoRow(
                                'Carrera:',
                                usuario.carrera!,
                                Icons.school,
                              ),
                            
                            if (usuario.ciclo != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Ciclo:',
                                usuario.ciclo!,
                                Icons.timeline,
                              ),
                            ],
                            
                            if (usuario.departamento != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Departamento:',
                                usuario.departamento!,
                                Icons.business,
                              ),
                            ],
                            
                            if (usuario.cargo != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Cargo:',
                                usuario.cargo!,
                                Icons.work,
                              ),
                            ],
                            
                            if (usuario.institucion != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Institución:',
                                usuario.institucion!,
                                Icons.apartment,
                              ),
                            ],
                            
                            const Divider(height: 24),
                            
                            _buildInfoRow(
                              'Registrado:',
                              DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                              Icons.access_time,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Información Importante',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ' Conserva esta confirmación como comprobante\n'
                            ' Llega 15 minutos antes del evento\n'
                            ' Presenta tu cédula al ingresar\n'
                            ' Para más información contacta al organizador',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Ir al Inicio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Registrar Otro Participante'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
