import 'package:employee_register_frontend/service/api_service.dart';
import 'package:flutter/material.dart';


class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void login(String username, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.login(username, password);
    if (response.statusCode == 200) {
      // Handle success (e.g., navigate to employee list screen)
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/employees');
    } else {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
