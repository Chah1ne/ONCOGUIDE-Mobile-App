import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

class SideEffectsService {
  static Future<List<dynamic>> fetchSideEffects(String token) async {
    final doctorId = Jwt.parseJwt(token)['id'];
    final Uri uri = Uri.parse('http://102.219.179.156:8082/side-effects/getAll/$doctorId');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load side effects');
    }
  }
  static Future<List<dynamic>> fetchSideEffectsHistory(String token) async {
    final doctorId = Jwt.parseJwt(token)['id'];
    final Uri uri = Uri.parse('http://102.219.179.156:8082/side-effects/getAllHistory/$doctorId');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };


    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load side effects');
    }
  }

  static Future<void> markSideEffectAsDone(String token, int sideEffectId, String doctorResponse) async {
    try {
      final Uri uri = Uri.parse('http://102.219.179.156:8082/side-effects/$sideEffectId');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      };

      // Decode the JWT token to get the user ID
      final doctorId = Jwt.parseJwt(token)['id'];

      // Include the user ID in the request body
      final Map<String, dynamic> body = {
        'doctorResponse': doctorResponse,
        'doctorId': doctorId, // Include the user ID here
      };

      final response = await http.put(uri, headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        // Side effect marked as done successfully
      } else {
        throw Exception('Failed to mark side effect as done');
      }
    } catch (error) {
      throw Exception('Error marking side effect as done: $error');
    }
  }

  static Future<void> associateDoctorWithPatient(String token, int userId) async {
    try {
      final Uri uri = Uri.parse('http://102.219.179.156:8082/side-effects/associateDoctorWithPatient');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      };

      // Decode the JWT token to get the user ID
      final doctorId = Jwt.parseJwt(token)['id'];

      // Include the user ID in the request body
      final Map<String, dynamic> body = {
        'doctorId': doctorId, // Include the user ID here
        'patientId': userId,
      };

      final response = await http.post(uri, headers: headers, body: json.encode(body));

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204 ) {
        // Side effect marked as done successfully
      } else {
        throw Exception('Failed to associate the doctor with the patient');
      }
    } catch (error) {
      throw Exception('Error associating the doctor with the patient: $error');
    }
  }

}
