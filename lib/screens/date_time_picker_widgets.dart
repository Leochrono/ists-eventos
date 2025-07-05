import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widgets personalizados para selección de fecha y hora con tema ISTS
class DateTimePickerWidgets {
  /// Color principal del tema ISTS
  static const Color _primaryColor = Color(0xFF2E7D32);

  /// Nombres de los meses en español
  static const List<String> _mesesEspanol = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  /// Muestra un selector de fecha personalizado con tema ISTS
  static Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 730)),
      helpText: helpText ?? 'Seleccionar fecha',
      cancelText: cancelText ?? 'Cancelar',
      confirmText: confirmText ?? 'Aceptar',
      fieldLabelText: 'Fecha',
      fieldHintText: 'dd/mm/yyyy',
      errorFormatText: 'Formato de fecha inválido',
      errorInvalidText: 'Fecha fuera del rango permitido',
      locale: const Locale('es', 'ES'), // AGREGAR ESTA LÍNEA
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              secondary: Color(0xFF4CAF50),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: _primaryColor,
              headerForegroundColor: Colors.white,
              weekdayStyle: const TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
              dayStyle: const TextStyle(
                color: Colors.black87,
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                _primaryColor.withValues(alpha: 0.3),
              ),
              todayForegroundColor: WidgetStateProperty.all(_primaryColor),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _primaryColor;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.black87;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Muestra un selector de hora personalizado con tema ISTS
  static Future<TimeOfDay?> showCustomTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
    bool use24HourFormat = true,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText ?? 'Seleccionar hora',
      cancelText: cancelText ?? 'Cancelar',
      confirmText: confirmText ?? 'Aceptar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minutos',
      errorInvalidText: 'Hora inválida',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: use24HourFormat,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteTextColor:
                    Colors.white, // Texto blanco en cuadros seleccionados
                dayPeriodTextColor: _primaryColor,
                dialHandColor: _primaryColor,
                dialTextColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors
                        .white; // TEXTO BLANCO cuando tiene fondo verde
                  }
                  return _primaryColor; // TEXTO VERDE cuando no está seleccionado
                }), // NÚMEROS DEL RELOJ EN VERDE
                entryModeIconColor: _primaryColor,
                helpTextStyle: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                dayPeriodTextStyle: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                hourMinuteTextStyle: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
                // ARREGLAR EL RELOJ CON ESTAS PROPIEDADES
                dialBackgroundColor: Colors.grey[50],
                hourMinuteColor:
                    _primaryColor, // CAMBIADO: Solo el color, sin WidgetStateProperty
              ),
              colorScheme: const ColorScheme.light(
                primary: _primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
                secondary: Color(0xFF4CAF50),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }

  /// Obtiene el nombre del mes en español
  static String getNombreMes(int mes) {
    if (mes < 1 || mes > 12) return '';
    return _mesesEspanol[mes];
  }

  /// Formatea una fecha en formato corto
  static String formatearFechaCorta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  /// Formatea una hora en formato 24 horas
  static String formatearHora24(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget personalizado para mostrar fecha seleccionada
class DateDisplayCard extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final String? errorText;

  const DateDisplayCard({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? Colors.red : Colors.grey[300]!,
            width: hasError ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasError ? Colors.red.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: hasError ? Colors.red : const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fecha *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasError ? Colors.red : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedDate.day} de ${DateTimePickerWidgets.getNombreMes(selectedDate.month)} de ${selectedDate.year}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: hasError ? Colors.red : Colors.black87,
              ),
            ),
            Text(
              DateTimePickerWidgets.formatearFechaCorta(selectedDate),
              style: TextStyle(
                fontSize: 12,
                color: hasError
                    ? Colors.red.withValues(alpha: 0.7)
                    : Colors.grey[600],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget personalizado para mostrar hora seleccionada
class TimeDisplayCard extends StatelessWidget {
  final TimeOfDay selectedTime;
  final VoidCallback onTap;
  final String? errorText;

  const TimeDisplayCard({
    super.key,
    required this.selectedTime,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? Colors.red : Colors.grey[300]!,
            width: hasError ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasError ? Colors.red.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: hasError ? Colors.red : const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hora *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasError ? Colors.red : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedTime.format(context),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: hasError ? Colors.red : Colors.black87,
              ),
            ),
            Text(
              DateTimePickerWidgets.formatearHora24(selectedTime),
              style: TextStyle(
                fontSize: 12,
                color: hasError
                    ? Colors.red.withValues(alpha: 0.7)
                    : Colors.grey[600],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
