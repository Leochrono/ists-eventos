import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../services/database_service.dart';

class ListaAsistentesScreen extends StatefulWidget {
  final Evento evento;

  const ListaAsistentesScreen({super.key, required this.evento});

  @override
  State<ListaAsistentesScreen> createState() => _ListaAsistentesScreenState();
}

class _ListaAsistentesScreenState extends State<ListaAsistentesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _asistentes = [];
  int _totalAsistentes = 0;
  bool _isLoading = true;
  String _filtroTipo = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _asistentesFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarAsistentes();
  }

  Future<void> _cargarAsistentes() async {
    setState(() => _isLoading = true);
    try {
      final asistentes = await _databaseService.getAsistenciaEvento(widget.evento.id!);
      final total = await _databaseService.getCountAsistencia(widget.evento.id!);
      
      setState(() {
        _asistentes = asistentes;
        _asistentesFiltrados = asistentes;
        _totalAsistentes = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _filtrarAsistentes() {
    List<Map<String, dynamic>> filtrados = _asistentes;
    
    if (_filtroTipo != 'Todos') {
      int tipoIndex = _getTipoIndex(_filtroTipo);
      filtrados = filtrados.where((asistente) => 
        asistente['tipo_usuario'] == tipoIndex).toList();
    }
    
    String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtrados = filtrados.where((asistente) {
        String nombre = '${asistente['nombres']} ${asistente['apellidos']}'.toLowerCase();
        String cedula = asistente['cedula'].toString().toLowerCase();
        return nombre.contains(query) || cedula.contains(query);
      }).toList();
    }
    
    setState(() {
      _asistentesFiltrados = filtrados;
    });
  }

  int _getTipoIndex(String tipo) {
    switch (tipo) {
      case 'Estudiante': return 0;
      case 'Docente': return 1;
      case 'Administrativo': return 2;
      case 'Invitado': return 3;
      default: return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Asistentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAsistentes,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF2E7D32).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.evento.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Asistentes',
                        _totalAsistentes.toString(),
                        Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Capacidad',
                        widget.evento.capacidadMaxima.toString(),
                        Icons.event_seat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Disponible',
                        (widget.evento.capacidadMaxima - _totalAsistentes).toString(),
                        Icons.event_available,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o cédula...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filtrarAsistentes(),
                ),
                
                const SizedBox(height: 12),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Todos',
                      'Estudiante',
                      'Docente',
                      'Administrativo',
                      'Invitado'
                    ].map((tipo) {
                      bool isSelected = _filtroTipo == tipo;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(tipo),
                          onSelected: (selected) {
                            setState(() {
                              _filtroTipo = tipo;
                            });
                            _filtrarAsistentes();
                          },
                          selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFF2E7D32),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _asistentesFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _asistentes.isEmpty
                                  ? 'No hay asistentes registrados'
                                  : 'No se encontraron asistentes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarAsistentes,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _asistentesFiltrados.length,
                          itemBuilder: (context, index) {
                            final asistente = _asistentesFiltrados[index];
                            return _buildAsistenteCard(asistente);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAsistenteCard(Map<String, dynamic> asistente) {
    final tipoUsuario = TipoUsuario.values[asistente['tipo_usuario']];
    final fechaAsistencia = DateTime.fromMillisecondsSinceEpoch(
      asistente['fecha_asistencia'],
    );
    
    IconData icono;
    Color color;
    
    switch (tipoUsuario) {
      case TipoUsuario.estudiante:
        icono = Icons.school;
        color = const Color(0xFF2E7D32);
        break;
      case TipoUsuario.docente:
        icono = Icons.person_outline;
        color = const Color(0xFF1976D2);
        break;
      case TipoUsuario.administrativo:
        icono = Icons.business_center;
        color = const Color(0xFF7B1FA2);
        break;
      case TipoUsuario.invitado:
        icono = Icons.group_add;
        color = const Color(0xFFFF6F00);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${asistente['nombres']} ${asistente['apellidos']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'CI: ${asistente['cedula']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tipoUsuario.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  if (asistente['carrera'] != null)
                    Text(
                      'Carrera: ${asistente['carrera']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  if (asistente['ciclo'] != null)
                    Text(
                      'Ciclo: ${asistente['ciclo']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  if (asistente['departamento'] != null)
                    Text(
                      'Depto: ${asistente['departamento']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  if (asistente['cargo'] != null)
                    Text(
                      'Cargo: ${asistente['cargo']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  if (asistente['institucion'] != null)
                    Text(
                      'Institución: ${asistente['institucion']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(fechaAsistencia),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd/MM').format(fechaAsistencia),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
