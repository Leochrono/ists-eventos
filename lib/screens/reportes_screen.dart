import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../services/database_service.dart';
import 'lista_asistentes_screen.dart';

class ReportesScreen extends StatefulWidget {
  final Evento evento;
  const ReportesScreen({super.key, required this.evento});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, int> _estadisticasTipoUsuario = {};
  int _totalAsistentes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);
    try {
      final asistentes = await _databaseService.getAsistenciaEvento(widget.evento.id!);
      final total = await _databaseService.getCountAsistencia(widget.evento.id!);
      Map<String, int> stats = {'Estudiante': 0, 'Docente': 0, 'Administrativo': 0, 'Invitado': 0};
      for (var asistente in asistentes) {
        final tipoIndex = asistente['tipo_usuario'] as int;
        final tipoNombre = ['Estudiante', 'Docente', 'Administrativo', 'Invitado'][tipoIndex];
        stats[tipoNombre] = (stats[tipoNombre] ?? 0) + 1;
      }
      setState(() {
        _estadisticasTipoUsuario = stats;
        _totalAsistentes = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Reportes del Evento'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => ListaAsistentesScreen(evento: widget.evento))),
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
    );
  }

  Widget _buildContent() {
    final porcentaje = _totalAsistentes > 0 ? ((_totalAsistentes / widget.evento.capacidadMaxima) * 100).round() : 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.evento.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(' ${DateFormat('dd/MM/yyyy HH:mm').format(widget.evento.fecha)}'),
              Text(' ${widget.evento.ubicacion}'),
            ]))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildStatCard(' Asistentes', _totalAsistentes.toString(), Colors.blue)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(' Capacidad', widget.evento.capacidadMaxima.toString(), Colors.green)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _buildStatCard(' Ocupación', '$porcentaje%', porcentaje > 80 ? Colors.red : Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(' Disponible', (widget.evento.capacidadMaxima - _totalAsistentes).toString(), Colors.grey)),
          ]),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(' Distribución por Tipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._estadisticasTipoUsuario.entries.map((entry) => _buildTipoRow(entry.key, entry.value)),
            ]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => ListaAsistentesScreen(evento: widget.evento))),
            icon: const Icon(Icons.list), label: const Text('Ver Lista Completa'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildTipoRow(String tipo, int cantidad) {
    final porcentaje = _totalAsistentes > 0 ? ((cantidad / _totalAsistentes) * 100).round() : 0;
    String emoji = tipo == 'Estudiante' ? '' : tipo == 'Docente' ? '' : tipo == 'Administrativo' ? '' : '';
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Text('$emoji $tipo', style: const TextStyle(fontWeight: FontWeight.w500)),
      const Spacer(),
      Text('$cantidad ($porcentaje%)', style: const TextStyle(fontWeight: FontWeight.bold)),
    ]));
  }
}
