import 'dart:convert';
// import 'dart:io';
import 'package:employee_register_frontend/models/employee.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:path_provider/path_provider.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final token = responseData['token'];
      await _storage.write(key: 'jwt_token', value: token);
    }

    return response;
  }

  Future<http.Response> getEmployees() async {
    try {
      final token = await _getToken();

      // Correctly create the Uri for the request
      final uri = Uri.parse('$baseUrl/employees');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response;
    } catch (e) {
      //print('Error occurred: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteEmployee(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/employees/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> createEmployee(Employee employee) async {
    final token = await _getToken();
    return http.post(
      Uri.parse('$baseUrl/employees'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(employee.toJson()),
    );
  }

  Future<http.Response> updateEmployee(int id, Employee employee) async {
    final token = await _getToken();
    return http.put(
      Uri.parse('$baseUrl/employees/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(employee.toJson()),
    );
  }

Future<http.Response> uploadProfilePicture(int id, String filePath) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/employees/$id/upload');
    
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..files.add(await http.MultipartFile.fromPath('file', filePath));
    
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> downloadProfilePicture(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/employees/$id/profile-picture'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  //  Future<File?> downloadProfilePicture(int id) async {
  //   final token = await _getToken();
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/employees/$id/profile-picture'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // Get the temporary directory where the image will be stored
  //     final directory = await getTemporaryDirectory();
  //     // Define the path to save the image
  //     final filePath = '${directory.path}/profile_picture_$id.png';

  //     // Save the image bytes to a file
  //     final file = File(filePath);
  //     await file.writeAsBytes(response.bodyBytes);

  //     // Return the file
  //     return file;
  //   } else {
  //     // Handle errors or return null if the download fails
  //     //print('Failed to download profile picture: ${response.statusCode}');
  //     return null;
  //   }
  // }
}
