import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import 'registro_usuario_form_screen.dart';

class SeleccionTipoUsuarioScreen extends StatelessWidget {
  final Evento evento;

  const SeleccionTipoUsuarioScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo de Usuario'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evento.nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                evento.ubicacion,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Selecciona tu tipo de usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Para registrar tu asistencia al evento, selecciona la opción que mejor te describa:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildTipoUsuarioCard(
              context,
              tipoUsuario: TipoUsuario.estudiante,
              titulo: 'Estudiante ISTS',
              descripcion: 'Estudiante del Instituto Superior Tecnológico Sudamericano',
              icono: Icons.school,
              color: const Color(0xFF2E7D32),
            ),
            
            const SizedBox(height: 12),
            
            _buildTipoUsuarioCard(
              context,
              tipoUsuario: TipoUsuario.docente,
              titulo: 'Docente',
              descripcion: 'Profesor o instructor del instituto',
              icono: Icons.person_outline,
              color: const Color(0xFF1976D2),
            ),
            
            const SizedBox(height: 12),
            
            _buildTipoUsuarioCard(
              context,
              tipoUsuario: TipoUsuario.administrativo,
              titulo: 'Personal Administrativo',
              descripcion: 'Personal administrativo del instituto',
              icono: Icons.business_center,
              color: const Color(0xFF7B1FA2),
            ),
            
            const SizedBox(height: 12),
            
            _buildTipoUsuarioCard(
              context,
              tipoUsuario: TipoUsuario.invitado,
              titulo: 'Invitado Externo',
              descripcion: 'Persona externa al instituto',
              icono: Icons.group_add,
              color: const Color(0xFFFF6F00),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF2E7D32),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Información importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      ' Tu información será registrada para el control de asistencia\n'
                      ' Los datos son confidenciales y solo para uso institucional\n'
                      ' Podrás actualizar tu información si es necesario\n'
                      ' El registro es obligatorio para participar en el evento',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoUsuarioCard(
    BuildContext context, {
    required TipoUsuario tipoUsuario,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroUsuarioFormScreen(
                evento: evento,
                tipoUsuario: tipoUsuario,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icono,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
