import 'dart:convert';
import 'package:http/http.dart' as http;

class MessagingService {
  static final String baseUrl = 'http://102.219.179.156:8082';
//192.168.100.207
  static Future createMessage(int senderId, int receiverId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/create'),
      body: {
        'senderId': senderId.toString(),
        'receiverId': receiverId.toString(),
        'message': message,
      },
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create message');
    }
  }

  static Future<List<dynamic>> getMessagesBetweenUsers(int userId1, int userId2) async {
    final response = await http.get(Uri.parse('$baseUrl/messages/$userId1/$userId2'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get messages');
    }
  }

  static Future<List<dynamic>> getUsersWithMessages(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/messages/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['users'];
    } else {
      throw Exception('Failed to get users with messages');
    }
  }
}
