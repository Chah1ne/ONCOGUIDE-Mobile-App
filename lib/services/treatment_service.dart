import 'dart:convert';
import 'package:http/http.dart' as http;

class AddTreatmentService {
  static Future<void> addIdManually(String userId, String manuallyAddedId, String? token) async {
    final url = Uri.parse('http://102.219.179.156:8082/user/updateRefCh/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': '$token',},
      body: jsonEncode({'ref_ch': manuallyAddedId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add ID manually');
    }
  }

  static Future<void> addIdManuallyWithBirthDate(String userId, String manuallyAddedId, String birthDate, String? token) async {
    final url = Uri.parse('http://102.219.179.156:8082/user/addIdManuallyWithBirthDate/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': '$token',},
      body: jsonEncode({'ref_ch': manuallyAddedId, 'birthDate': birthDate}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add ID manually');
    }
  }
}



class TreatmentService {
  Future<Map<String, dynamic>> fetchTreatmentProgress(int userId, String? token) async {
    final Uri uri = Uri.parse('http://102.219.179.156:8082/cure/getTreatmentProgress/$userId');
    final Map<String, String> headers = {'Authorization': '$token'};

    final http.Client client = http.Client();
    try {
      final response = await client.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch treatment progress');
      }
    } finally {
      client.close();
    }
  }
}