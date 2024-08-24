import 'dart:convert';
import 'dart:io';
import 'package:employee_register_frontend/service/api_service.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  void fetchEmployees() async {
    try {
      final response = await _apiService.getEmployees();

      if (response.statusCode == 200) {
        // Debugging: Print response body to check the format
        //print('Response body: ${response.body}');

        // Decode response body and convert to list of Employee objects
        final List<dynamic> data = jsonDecode(response.body);
        _employees = data.map((json) => Employee.fromJson(json)).toList();
        notifyListeners();
      } else {
        // Handle non-successful response
        //print('Failed to load employees: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle error
      //print('Error occurred: $e');
    }
  }

  void deleteEmployee(int id) async {
    try {
      final response = await _apiService.deleteEmployee(id);

      if (response.statusCode == 200) {
        fetchEmployees(); // Refresh the employee list
      } else {
        // Handle non-successful response
        //print('Failed to delete employee: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle error
      //print('Error occurred: $e');
    }
  }

  void createEmployee(Employee employee) async {
    try {
      final response = await _apiService.createEmployee(employee);

      if (response.statusCode == 200) {
        // HTTP 201 indicates successful creation
        fetchEmployees(); // Refresh the employee list
      } else {
        //print('Failed to create employee: ${response.reasonPhrase}');
      }
    } catch (e) {
      //print('Error occurred: $e');
    }
  }

  void updateEmployee(int id, Employee employee) async {
    try {
      final response = await _apiService.updateEmployee(id, employee);

      if (response.statusCode == 200) {
        // HTTP 200 indicates successful update
        fetchEmployees(); // Refresh the employee list
      } else {
        //print('Failed to update employee: ${response.reasonPhrase}');
      }
    } catch (e) {
      //print('Error occurred: $e');
    }
  }

  void uploadProfilePicture(int id, String filePath) async {
    try {
      final response = await _apiService.uploadProfilePicture(id, filePath);

      if (response.statusCode == 200) {
        //print('Profile picture uploaded successfully!');
        // Optionally, you can fetch the employee list again if needed
        // fetchEmployees();
      } else {
        //print('Failed to upload profile picture: ${response.reasonPhrase}');
      }
    } catch (e) {
      //print('Error occurred: $e');
    }
  }

  Future<File?> downloadProfilePicture(int employeeId) async {
    try {
      final response = await _apiService.downloadProfilePicture(employeeId);

      if (response.statusCode == 200) {
        // Save to a temporary directory or cache
        final tempDir = Directory.systemTemp;
        final filePath = '${tempDir.path}/profile_picture_$employeeId';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        //print('Failed to download profile picture: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      //print('Error occurred: $e');
      return null;
    }
  }
}
