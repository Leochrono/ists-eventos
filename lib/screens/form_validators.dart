import 'package:flutter/material.dart';

/// Clase que contiene todas las validaciones para formularios de la aplicación ISTS Eventos
class FormValidators {
  
  // ============================================================================
  // VALIDACIONES PARA EVENTOS
  // ============================================================================
  
  /// Valida el nombre del evento
  static String? validateEventName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del evento es obligatorio';
    }
    
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    
    if (value.trim().length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    
    // Verificar que no sea solo números
    if (RegExp(r'^[0-9\s]+$').hasMatch(value.trim())) {
      return 'El nombre no puede ser solo números';
    }
    
    // Verificar que no contenga solo caracteres especiales
    if (RegExp(r'^[\W\s]+$').hasMatch(value.trim())) {
      return 'El nombre debe contener letras';
    }
    
    return null;
  }

  /// Valida la descripción del evento
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es obligatoria';
    }
    
    if (value.trim().length < 10) {
      return 'La descripción debe ser más detallada (mínimo 10 caracteres)';
    }
    
    if (value.trim().length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    
    // Verificar que no sea solo números o caracteres especiales
    if (RegExp(r'^[0-9\W\s]+$').hasMatch(value.trim())) {
      return 'La descripción debe contener texto descriptivo';
    }
    
    return null;
  }

  /// Valida la ubicación del evento
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La ubicación es obligatoria';
    }
    
    if (value.trim().length < 3) {
      return 'La ubicación debe tener al menos 3 caracteres';
    }
    
    if (value.trim().length > 200) {
      return 'La ubicación no puede exceder 200 caracteres';
    }
    
    return null;
  }

  /// Valida el organizador del evento
  static String? validateOrganizer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El organizador es obligatorio';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre del organizador debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 100) {
      return 'El nombre del organizador no puede exceder 100 caracteres';
    }
    
    // Verificar que no sea solo números
    if (RegExp(r'^[0-9\s]+$').hasMatch(value.trim())) {
      return 'El organizador no puede ser solo números';
    }
    
    return null;
  }

  /// Valida la capacidad del evento
  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La capacidad es obligatoria';
    }
    
    final capacity = int.tryParse(value.trim());
    if (capacity == null) {
      return 'Ingresa un número válido';
    }
    
    if (capacity <= 0) {
      return 'La capacidad debe ser mayor a 0';
    }
    
    if (capacity < 5) {
      return 'La capacidad mínima es de 5 personas';
    }
    
    if (capacity > 10000) {
      return 'La capacidad no puede exceder 10,000 personas';
    }
    
    return null;
  }

  /// Valida la capacidad según el tipo de evento
  static String? validateCapacityByEventType(String? capacity, String? eventName) {
    final basicValidation = validateCapacity(capacity);
    if (basicValidation != null) return basicValidation;

    final cap = int.parse(capacity!);
    final name = eventName?.toLowerCase() ?? '';

    if (name.contains('conferencia') || name.contains('congreso')) {
      if (cap < 30) return 'Una conferencia usualmente tiene al menos 30 participantes';
      if (cap > 500) return 'Considera dividir en múltiples sesiones para más de 500 personas';
    } else if (name.contains('taller') || name.contains('laboratorio')) {
      if (cap > 25) return 'Un taller es más efectivo con máximo 25 participantes';
      if (cap < 5) return 'Un taller necesita al menos 5 participantes';
    } else if (name.contains('seminario') || name.contains('curso')) {
      if (cap > 40) return 'Un seminario es más efectivo con máximo 40 participantes';
    }

    return null;
  }

  // ============================================================================
  // VALIDACIONES DE FECHA Y HORA
  // ============================================================================

  /// Valida la fecha del evento
  static String? validateEventDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return 'Selecciona una fecha para el evento';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (eventDate.isBefore(today)) {
      return 'La fecha del evento no puede ser en el pasado';
    }

    final maxDate = today.add(const Duration(days: 365 * 2)); // 2 años en el futuro
    if (eventDate.isAfter(maxDate)) {
      return 'La fecha del evento no puede ser más de 2 años en el futuro';
    }

    // Validar que no sea un domingo (opcional)
    if (selectedDate.weekday == DateTime.sunday) {
      return 'Los eventos usualmente no se programan los domingos';
    }

    return null;
  }

  /// Valida la hora del evento
  static String? validateEventTime(DateTime? selectedDate, TimeOfDay? selectedTime) {
    if (selectedTime == null) {
      return 'Selecciona una hora para el evento';
    }

    if (selectedDate == null) {
      return null; // Si no hay fecha, no podemos validar la hora
    }

    final now = DateTime.now();
    final eventDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Si el evento es hoy, verificar que la hora sea en el futuro
    if (selectedDate.year == now.year && 
        selectedDate.month == now.month && 
        selectedDate.day == now.day) {
      if (eventDateTime.isBefore(now.add(const Duration(hours: 2)))) {
        return 'El evento debe ser al menos 2 horas en el futuro si es hoy';
      }
    }

    return null;
  }

  /// Valida horarios institucionales (horarios de clases)
  static String? validateInstitutionalTime(TimeOfDay? time) {
    if (time == null) return 'Selecciona una hora';

    // Horarios institucionales del ISTS
    final morningStart = const TimeOfDay(hour: 7, minute: 0);
    final morningEnd = const TimeOfDay(hour: 12, minute: 30);
    final afternoonStart = const TimeOfDay(hour: 14, minute: 0);
    final eveningEnd = const TimeOfDay(hour: 21, minute: 30);

    final timeInMinutes = time.hour * 60 + time.minute;
    final morningStartMinutes = morningStart.hour * 60 + morningStart.minute;
    final morningEndMinutes = morningEnd.hour * 60 + morningEnd.minute;
    final afternoonStartMinutes = afternoonStart.hour * 60 + afternoonStart.minute;
    final eveningEndMinutes = eveningEnd.hour * 60 + eveningEnd.minute;

    final isInMorningSchedule = timeInMinutes >= morningStartMinutes && timeInMinutes <= morningEndMinutes;
    final isInAfternoonSchedule = timeInMinutes >= afternoonStartMinutes && timeInMinutes <= eveningEndMinutes;

    if (!isInMorningSchedule && !isInAfternoonSchedule) {
      return 'Horario sugerido: 07:00-12:30 o 14:00-21:30';
    }

    return null;
  }

  /// Validación combinada de fecha y hora
  static String? validateDateTime(DateTime? selectedDate, TimeOfDay? selectedTime) {
    final dateError = validateEventDate(selectedDate);
    if (dateError != null) return dateError;

    final timeError = validateEventTime(selectedDate, selectedTime);
    if (timeError != null) return timeError;

    return null;
  }

  // ============================================================================
  // VALIDACIONES PARA USUARIOS
  // ============================================================================

  /// Valida cédula ecuatoriana
  static String? validateCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cédula es obligatoria';
    }
    
    // Remover espacios
    value = value.replaceAll(' ', '');
    
    if (value.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'La cédula solo puede contener números';
    }
    
    // Validar que los primeros dos dígitos correspondan a una provincia válida
    final provincia = int.tryParse(value.substring(0, 2));
    if (provincia == null || provincia < 1 || provincia > 24) {
      return 'Los primeros dos dígitos deben corresponder a una provincia válida (01-24)';
    }
    
    // Validar dígito verificador (algoritmo estándar de cédula ecuatoriana)
    if (!_validarDigitoVerificadorCedula(value)) {
      return 'Número de cédula inválido';
    }
    
    return null;
  }

  /// Valida nombres
  static String? validateNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los nombres son obligatorios';
    }
    
    if (value.trim().length < 2) {
      return 'Los nombres deben tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'Los nombres no pueden exceder 50 caracteres';
    }
    
    // Solo letras, espacios y algunos caracteres especiales (tildes, ñ)
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
      return 'Los nombres solo pueden contener letras';
    }
    
    return null;
  }

  /// Valida apellidos
  static String? validateLastNames(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los apellidos son obligatorios';
    }
    
    if (value.trim().length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'Los apellidos no pueden exceder 50 caracteres';
    }
    
    // Solo letras, espacios y algunos caracteres especiales (tildes, ñ)
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
      return 'Los apellidos solo pueden contener letras';
    }
    
    return null;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    
    // Expresión regular para email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    
    // Validaciones adicionales para emails institucionales
    final email = value.trim().toLowerCase();
    if (email.endsWith('@ists.edu.ec')) {
      return null; // Email institucional válido
    }
    
    // Sugerir usar email institucional para estudiantes y personal
    return null; // Permitir emails externos también
  }

  /// Valida teléfono ecuatoriano
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }
    
    // Remover espacios y guiones
    value = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono solo puede contener números';
    }
    
    if (value.length == 9) {
      // Teléfono fijo (9 dígitos)
      if (!value.startsWith('0')) {
        return 'Teléfono fijo debe comenzar con 0';
      }
    } else if (value.length == 10) {
      // Teléfono móvil (10 dígitos)
      if (!value.startsWith('09')) {
        return 'Teléfono móvil debe comenzar con 09';
      }
    } else {
      return 'Teléfono debe tener 9 dígitos (fijo) o 10 dígitos (móvil)';
    }
    
    return null;
  }

  // ============================================================================
  // VALIDACIONES ESPECÍFICAS PARA ISTS
  // ============================================================================

  /// Valida carrera del ISTS
  static String? validateCareer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecciona tu carrera';
    }
    
    return null;
  }

  /// Valida ciclo académico
  static String? validateAcademicCycle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecciona tu ciclo académico';
    }
    
    return null;
  }

  /// Valida departamento
  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecciona tu departamento';
    }
    
    return null;
  }

  /// Valida cargo
  static String? validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El cargo es obligatorio';
    }
    
    if (value.trim().length < 2) {
      return 'El cargo debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 100) {
      return 'El cargo no puede exceder 100 caracteres';
    }
    
    return null;
  }

  /// Valida institución externa
  static String? validateInstitution(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La institución es obligatoria para invitados externos';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre de la institución debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 200) {
      return 'El nombre de la institución no puede exceder 200 caracteres';
    }
    
    return null;
  }

  /// Valida motivo de participación
  static String? validateParticipationReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El motivo de participación es obligatorio';
    }
    
    if (value.trim().length < 10) {
      return 'Describe brevemente tu motivo de participación (mín. 10 caracteres)';
    }
    
    if (value.trim().length > 300) {
      return 'El motivo no puede exceder 300 caracteres';
    }
    
    return null;
  }

  // ============================================================================
  // VALIDACIONES AUXILIARES
  // ============================================================================

  /// Valida campos de texto requeridos
  static String? validateRequiredText(String? value, String fieldName, {int minLength = 1, int maxLength = 255}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    
    return null;
  }

  /// Valida que el evento tenga características académicas
  static String? validateAcademicEventContext(String? eventName, String? description) {
    if (eventName == null && description == null) return null;
    
    final academicKeywords = [
      'conferencia', 'seminario', 'taller', 'capacitación', 'curso',
      'congreso', 'simposio', 'foro', 'mesa redonda', 'presentación',
      'charla', 'exposición', 'encuentro', 'jornada', 'webinar',
      'workshop', 'laboratorio', 'práctica', 'académico', 'educativo'
    ];

    final combinedText = '${eventName ?? ''} ${description ?? ''}'.toLowerCase();
    final hasAcademicContext = academicKeywords.any((keyword) =>
        combinedText.contains(keyword));

    if (!hasAcademicContext) {
      return 'Sugerencia: Especifica el tipo de evento académico (conferencia, taller, etc.)';
    }

    return null;
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ============================================================================

  /// Valida el dígito verificador de la cédula ecuatoriana
  static bool _validarDigitoVerificadorCedula(String cedula) {
    final coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;
    
    for (int i = 0; i < 9; i++) {
      int digito = int.parse(cedula[i]);
      int producto = digito * coeficientes[i];
      
      if (producto >= 10) {
        producto = producto - 9;
      }
      
      suma += producto;
    }
    
    int residuo = suma % 10;
    int digitoVerificador = residuo == 0 ? 0 : 10 - residuo;
    
    return digitoVerificador == int.parse(cedula[9]);
  }

  // ============================================================================
  // VALIDACIONES DE FORMULARIOS COMPLETOS
  // ============================================================================

  /// Valida un formulario de evento completo
  static List<String> validateEventForm({
    required String? nombre,
    required String? descripcion,
    required String? ubicacion,
    required String? organizador,
    required String? capacidad,
    required DateTime? fecha,
    required TimeOfDay? hora,
  }) {
    List<String> errors = [];
    
    final nombreError = validateEventName(nombre);
    if (nombreError != null) errors.add(nombreError);
    
    final descripcionError = validateDescription(descripcion);
    if (descripcionError != null) errors.add(descripcionError);
    
    final ubicacionError = validateLocation(ubicacion);
    if (ubicacionError != null) errors.add(ubicacionError);
    
    final organizadorError = validateOrganizer(organizador);
    if (organizadorError != null) errors.add(organizadorError);
    
    final capacidadError = validateCapacityByEventType(capacidad, nombre);
    if (capacidadError != null) errors.add(capacidadError);
    
    final fechaError = validateEventDate(fecha);
    if (fechaError != null) errors.add(fechaError);
    
    final horaError = validateEventTime(fecha, hora);
    if (horaError != null) errors.add(horaError);
    
    final contextoError = validateAcademicEventContext(nombre, descripcion);
    if (contextoError != null) errors.add(contextoError);
    
    return errors;
  }
}