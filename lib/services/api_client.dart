import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://102.219.179.156:8082";

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to perform request');
    }
  }
  Future<void> sendPasswordResetCode(String email) async {final response = await http.post(
      Uri.parse('$baseUrl/user/password/sendVerificationCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{ 'email': email }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send password reset code');
    }
  }
  Future<void> resetPassword(String email, String code, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/password/changePassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'newPassword': newPassword,
        'verificationCode': code,

      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password');
    }
  }
}