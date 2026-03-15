import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  bool _initialized = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get initialized => _initialized;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final token = await getToken();
      if (token != null) {
        _user = await apiGetMe();
      }
    } catch (_) {
      await clearToken().catchError((_) {});
      _user = null;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }
  Future<void> signUp(String name, String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await apiRegister(name, email, password);
      _user = result.user;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await apiLogin(email, password);
      _user = result.user;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await apiLogout();
    _user = null;
    notifyListeners();
  }
}
