// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_exception.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) await prefs.setString(_tokenKey, accessToken);
    if (refreshToken != null) await prefs.setString(_refreshTokenKey, refreshToken);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    final apiService = ApiService();
    final response = await apiService.login(email, password);
    
    await saveTokens(
      accessToken: response['access'],
      refreshToken: response['refresh'],
      userEmail: email,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userEmailKey);
  }
}
