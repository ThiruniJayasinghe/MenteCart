import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/failures.dart';

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/auth/login', data: {'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['token']);
    return data;
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final data = await _api.post('/auth/signup', data: {'name': name, 'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['token']);
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<Map<String, dynamic>> getMe() async {
    return _api.get('/auth/me');
  }
}