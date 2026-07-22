import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthState state = AuthState.unknown;
  String?   token;
  String?   phone;
  String?   name;

  ApiService get api => ApiService(token: token);

  AuthProvider() { _tryAutoLogin(); }

  Future<void> _tryAutoLogin() async {
    final saved = await StorageService.getToken();
    if (saved != null) {
      token = saved;
      phone = await StorageService.getPhone();
      name  = await StorageService.getName();
      state = AuthState.authenticated;
    } else {
      state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    await ApiService().sendOtp(phone);
  }

  Future<void> verifyOtp(String phoneNumber, String code) async {
    final data = await ApiService().verifyOtp(phoneNumber, code);
    token = data['token'];
    phone = data['user']['phone'];
    name  = data['user']['name'];
    state = AuthState.authenticated;
    await StorageService.saveAuth(token: token!, phone: phone!, name: name);
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    token = null; phone = null; name = null;
    state = AuthState.unauthenticated;
    notifyListeners();
  }
}
