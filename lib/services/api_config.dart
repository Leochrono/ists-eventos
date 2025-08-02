// lib/services/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api';
  
  static const String eventos = '$apiVersion/eventos/';
  static const String carreras = '$apiVersion/carreras/';
  static const String tiposEvento = '$apiVersion/tipos-evento/';
  static const String secciones = '$apiVersion/secciones/';
  static const String asignarCarreras = '$apiVersion/asignar-carreras/';
  static const String registrarEvento = '$apiVersion/registrar-evento/';
  static const String seleccionarSecciones = '$apiVersion/seleccionar-secciones/';
  static const String consultarUsuario = '$apiVersion/consultar-usuario/';
  static const String scan = '$apiVersion/scan/';
  static const String report = '$apiVersion/report/';
  static const String token = '$apiVersion/token/';
  static const String tokenRefresh = '$apiVersion/token/refresh/';
  static const String tokenVerify = '$apiVersion/token/verify/';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
