import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../models/asistencia.dart';
import '../services/database_service.dart';
import 'confirmacion_registro_screen.dart';

class RegistroUsuarioFormScreen extends StatefulWidget {
  final Evento evento;
  final TipoUsuario tipoUsuario;

  const RegistroUsuarioFormScreen({
    super.key,
    required this.evento,
    required this.tipoUsuario,
  });

  @override
  State<RegistroUsuarioFormScreen> createState() => _RegistroUsuarioFormScreenState();
}

class _RegistroUsuarioFormScreenState extends State<RegistroUsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  final _carreraController = TextEditingController();
  final _cicloController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _cargoController = TextEditingController();
  final _institucionController = TextEditingController();
  final _motivoController = TextEditingController();
  
  String? _carreraSeleccionada;
  String? _cicloSeleccionado;
  String? _departamentoSeleccionado;
  
  bool _isLoading = false;
  bool _usuarioExistente = false;
  Usuario? _usuarioEncontrado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro - ${widget.tipoUsuario.name.toUpperCase()}'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              
              const SizedBox(height: 24),
              
              _buildSeccionComun(),
              
              const SizedBox(height: 24),
              
              _buildSeccionEspecifica(),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrarUsuario,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                              Text('Registrando...'),
                            ],
                          )
                        : Text(
                            _usuarioExistente ? 'Confirmar Asistencia' : 'Registrar Asistencia',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    IconData icono;
    Color color;
    String descripcion;
    
    switch (widget.tipoUsuario) {
      case TipoUsuario.estudiante:
        icono = Icons.school;
        color = const Color(0xFF2E7D32);
        descripcion = 'Estudiante del ISTS';
        break;
      case TipoUsuario.docente:
        icono = Icons.person_outline;
        color = const Color(0xFF1976D2);
        descripcion = 'Docente del instituto';
        break;
      case TipoUsuario.administrativo:
        icono = Icons.business_center;
        color = const Color(0xFF7B1FA2);
        descripcion = 'Personal administrativo';
        break;
      case TipoUsuario.invitado:
        icono = Icons.group_add;
        color = const Color(0xFFFF6F00);
        descripcion = 'Invitado externo';
        break;
    }
    
    return Card(
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
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tipoUsuario.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionComun() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _cedulaController,
          decoration: const InputDecoration(
            labelText: 'Cédula de Identidad *',
            hintText: '1234567890',
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La cédula es obligatoria';
            }
            if (value.length != 10) {
              return 'La cédula debe tener 10 dígitos';
            }
            return null;
          },
          onChanged: _buscarUsuarioExistente,
        ),
        
        if (_usuarioExistente) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usuario encontrado: ${_usuarioEncontrado?.nombreCompleto}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _nombresController,
          decoration: const InputDecoration(
            labelText: 'Nombres *',
            hintText: 'Juan Carlos',
            prefixIcon: Icon(Icons.person),
          ),
          enabled: !_usuarioExistente,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Los nombres son obligatorios';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _apellidosController,
          decoration: const InputDecoration(
            labelText: 'Apellidos *',
            hintText: 'Pérez García',
            prefixIcon: Icon(Icons.person_outline),
          ),
          enabled: !_usuarioExistente,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Los apellidos son obligatorios';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo Electrónico *',
            hintText: 'ejemplo@email.com',
            prefixIcon: Icon(Icons.email),
          ),
          enabled: !_usuarioExistente,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El email es obligatorio';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Ingresa un email válido';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono *',
            hintText: '0987654321',
            prefixIcon: Icon(Icons.phone),
          ),
          enabled: !_usuarioExistente,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El teléfono es obligatorio';
            }
            if (value.length < 9) {
              return 'Ingresa un teléfono válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSeccionEspecifica() {
    switch (widget.tipoUsuario) {
      case TipoUsuario.estudiante:
        return _buildFormularioEstudiante();
      case TipoUsuario.docente:
        return _buildFormularioDocente();
      case TipoUsuario.administrativo:
        return _buildFormularioAdministrativo();
      case TipoUsuario.invitado:
        return _buildFormularioInvitado();
    }
  }

  Widget _buildFormularioEstudiante() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Académica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _carreraSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Carrera *',
            prefixIcon: Icon(Icons.book),
          ),
          items: CarrerasISTS.carreras.map((carrera) {
            return DropdownMenuItem(
              value: carrera,
              child: Text(carrera),
            );
          }).toList(),
          onChanged: _usuarioExistente ? null : (value) {
            setState(() {
              _carreraSeleccionada = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona tu carrera';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _cicloSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Ciclo Académico *',
            prefixIcon: Icon(Icons.timeline),
          ),
          items: CarrerasISTS.ciclos.map((ciclo) {
            return DropdownMenuItem(
              value: ciclo,
              child: Text(ciclo),
            );
          }).toList(),
          onChanged: _usuarioExistente ? null : (value) {
            setState(() {
              _cicloSeleccionado = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona tu ciclo académico';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormularioDocente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Profesional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _carreraSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Carrera/Área de Enseñanza *',
            prefixIcon: Icon(Icons.school),
          ),
          items: CarrerasISTS.carreras.map((carrera) {
            return DropdownMenuItem(
              value: carrera,
              child: Text(carrera),
            );
          }).toList(),
          onChanged: _usuarioExistente ? null : (value) {
            setState(() {
              _carreraSeleccionada = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona el área de enseñanza';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _cargoController,
          decoration: const InputDecoration(
            labelText: 'Cargo *',
            hintText: 'Docente Titular, Docente de Cátedra, etc.',
            prefixIcon: Icon(Icons.work),
          ),
          enabled: !_usuarioExistente,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El cargo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormularioAdministrativo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Laboral',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _departamentoSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Departamento *',
            prefixIcon: Icon(Icons.business),
          ),
          items: CarrerasISTS.departamentos.map((depto) {
            return DropdownMenuItem(
              value: depto,
              child: Text(depto),
            );
          }).toList(),
          onChanged: _usuarioExistente ? null : (value) {
            setState(() {
              _departamentoSeleccionado = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona tu departamento';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _cargoController,
          decoration: const InputDecoration(
            labelText: 'Cargo *',
            hintText: 'Secretaria, Contador, Técnico, etc.',
            prefixIcon: Icon(Icons.badge),
          ),
          enabled: !_usuarioExistente,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El cargo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormularioInvitado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del Invitado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _institucionController,
          decoration: const InputDecoration(
            labelText: 'Institución/Empresa *',
            hintText: 'Universidad, Empresa, Organización, etc.',
            prefixIcon: Icon(Icons.apartment),
          ),
          enabled: !_usuarioExistente,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La institución es obligatoria';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _motivoController,
          decoration: const InputDecoration(
            labelText: 'Motivo de Participación *',
            hintText: 'Conferencia, capacitación, reunión, etc.',
            prefixIcon: Icon(Icons.comment),
          ),
          enabled: !_usuarioExistente,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El motivo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _buscarUsuarioExistente(String cedula) async {
    if (cedula.length == 10) {
      final usuario = await _databaseService.getUsuarioPorCedula(cedula);
      if (usuario != null) {
        setState(() {
          _usuarioExistente = true;
          _usuarioEncontrado = usuario;
          
          _nombresController.text = usuario.nombres;
          _apellidosController.text = usuario.apellidos;
          _emailController.text = usuario.email;
          _telefonoController.text = usuario.telefono;
          _carreraSeleccionada = usuario.carrera;
          _cicloSeleccionado = usuario.ciclo;
          _departamentoSeleccionado = usuario.departamento;
          _cargoController.text = usuario.cargo ?? '';
          _institucionController.text = usuario.institucion ?? '';
          _motivoController.text = usuario.motivo ?? '';
        });
      } else {
        setState(() {
          _usuarioExistente = false;
          _usuarioEncontrado = null;
        });
      }
    }
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      Usuario usuario;
      
      if (_usuarioExistente && _usuarioEncontrado != null) {
        usuario = _usuarioEncontrado!;
      } else {
        usuario = Usuario(
          cedula: _cedulaController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          email: _emailController.text.trim(),
          telefono: _telefonoController.text.trim(),
          tipoUsuario: widget.tipoUsuario,
          carrera: _carreraSeleccionada,
          ciclo: _cicloSeleccionado,
          departamento: _departamentoSeleccionado,
          cargo: _cargoController.text.trim().isEmpty ? null : _cargoController.text.trim(),
          institucion: _institucionController.text.trim().isEmpty ? null : _institucionController.text.trim(),
          motivo: _motivoController.text.trim().isEmpty ? null : _motivoController.text.trim(),
        );
        
        final userId = await _databaseService.insertUsuario(usuario);
        usuario = usuario.copyWith(id: userId);
      }
      
      final yaRegistrado = await _databaseService.yaRegistradoEnEvento(
        widget.evento.id!,
        usuario.id!,
      );
      
      if (yaRegistrado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya estás registrado en este evento'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final asistencia = Asistencia(
        eventoId: widget.evento.id!,
        usuarioId: usuario.id!,
      );
      
      await _databaseService.registrarAsistencia(asistencia);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacionRegistroScreen(
              evento: widget.evento,
              usuario: usuario,
            ),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _carreraController.dispose();
    _cicloController.dispose();
    _departamentoController.dispose();
    _cargoController.dispose();
    _institucionController.dispose();
    _motivoController.dispose();
    super.dispose();
  }
}
