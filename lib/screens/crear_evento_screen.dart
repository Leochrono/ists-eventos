import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../services/database_service.dart';
import 'form_validators.dart';
import 'date_time_picker_widgets.dart';

class CrearEventoScreen extends StatefulWidget {
  final Evento? evento;
  
  const CrearEventoScreen({super.key, this.evento});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _organizadorController;
  late TextEditingController _capacidadController;
  
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);
  
  bool _isLoading = false;
  bool get _isEditing => widget.evento != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final evento = widget.evento;
    
    _nombreController = TextEditingController(text: evento?.nombre ?? '');
    _descripcionController = TextEditingController(text: evento?.descripcion ?? '');
    _ubicacionController = TextEditingController(text: evento?.ubicacion ?? '');
    _organizadorController = TextEditingController(text: evento?.organizador ?? '');
    _capacidadController = TextEditingController(
      text: evento?.capacidadMaxima.toString() ?? '50'
    );
    
    if (evento != null) {
      _fechaSeleccionada = DateTime(
        evento.fecha.year,
        evento.fecha.month,
        evento.fecha.day,
      );
      _horaSeleccionada = TimeOfDay(
        hour: evento.fecha.hour,
        minute: evento.fecha.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Evento' : 'Crear Evento'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInstitutionHeader(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 32),
            _buildQRInfoCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildInstitutionHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instituto Superior Tecnológico Sudamericano',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    'Sistema de Gestión de Eventos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Información Básica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Evento *',
                hintText: 'Ej: Conferencia de Tecnología 2025',
                prefixIcon: Icon(Icons.event),
                helperText: 'Especifica el tipo de evento (conferencia, taller, etc.)',
              ),
              validator: FormValidators.validateEventName,
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Describe el evento, actividades, objetivos...',
                prefixIcon: Icon(Icons.description),
                helperText: 'Incluye detalles importantes para los participantes',
              ),
              maxLines: 3,
              validator: FormValidators.validateDescription,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fecha y Hora',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: DateDisplayCard(
                    selectedDate: _fechaSeleccionada,
                    onTap: _seleccionarFecha,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TimeDisplayCard(
                    selectedTime: _horaSeleccionada,
                    onTap: _seleccionarHora,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Mostrar validaciones de fecha y hora
            _buildDateTimeValidations(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeValidations() {
    final dateError = FormValidators.validateEventDate(_fechaSeleccionada);
    final timeError = FormValidators.validateInstitutionalTime(_horaSeleccionada);
    
    if (dateError == null && timeError == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[700],
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Fecha y hora válidas para el evento',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        if (dateError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateError,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (timeError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.orange[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timeError,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Detalles Adicionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación *',
                hintText: 'Ej: Auditorio Principal, Aula 201, Campus ISTS',
                prefixIcon: Icon(Icons.location_on),
                helperText: 'Especifica el lugar exacto del evento',
              ),
              validator: FormValidators.validateLocation,
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _organizadorController,
              decoration: const InputDecoration(
                labelText: 'Organizador *',
                hintText: 'Nombre del responsable o departamento',
                prefixIcon: Icon(Icons.person),
                helperText: 'Persona o área responsable del evento',
              ),
              validator: FormValidators.validateOrganizer,
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _capacidadController,
              decoration: const InputDecoration(
                labelText: 'Capacidad Máxima *',
                hintText: 'Número máximo de participantes',
                prefixIcon: Icon(Icons.people),
                suffixText: 'personas',
                helperText: 'Considera el espacio disponible',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => FormValidators.validateCapacityByEventType(
                value, 
                _nombreController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRInfoCard() {
    return Card(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.05),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Icons.qr_code,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Código QR Automático',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✓ Se generará automáticamente un código QR único\n'
              '✓ Contiene toda la información del evento\n'
              '✓ Compatible con cualquier aplicación de QR\n'
              '✓ Los participantes pueden registrarse escaneándolo',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _guardarEvento,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white, // TEXTO EN BLANCO
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.white, // TEXTO BLANCO CUANDO ESTÁ DESHABILITADO
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Guardando...',
                          style: TextStyle(
                            color: Colors.white, // TEXTO BLANCO EXPLÍCITO
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _isEditing ? 'Actualizar Evento' : 'Crear Evento',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // TEXTO BLANCO EXPLÍCITO
                      ),
                    ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _eliminarEvento,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Eliminar Evento',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final selectedDate = await DateTimePickerWidgets.showCustomDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      helpText: 'Fecha del Evento',
    );
    
    if (selectedDate != null) {
      setState(() {
        _fechaSeleccionada = selectedDate;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final selectedTime = await DateTimePickerWidgets.showCustomTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      helpText: 'Hora del Evento',
    );
    
    if (selectedTime != null) {
      setState(() {
        _horaSeleccionada = selectedTime;
      });
    }
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar fecha y hora
    final dateTimeError = FormValidators.validateDateTime(_fechaSeleccionada, _horaSeleccionada);
    if (dateTimeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateTimeError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fechaCompleta = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaSeleccionada.hour,
        _horaSeleccionada.minute,
      );

      final evento = Evento(
        id: widget.evento?.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fecha: fechaCompleta,
        ubicacion: _ubicacionController.text.trim(),
        organizador: _organizadorController.text.trim(),
        capacidadMaxima: int.parse(_capacidadController.text.trim()),
        fechaCreacion: widget.evento?.fechaCreacion,
      );

      if (_isEditing) {
        await _databaseService.updateEvento(evento);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento actualizado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } else {
        await _databaseService.insertEvento(evento);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento creado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarEvento() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar eliminación'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && widget.evento?.id != null) {
      setState(() => _isLoading = true);
      try {
        await _databaseService.deleteEvento(widget.evento!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento eliminado exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _organizadorController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }
}