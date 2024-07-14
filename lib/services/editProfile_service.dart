import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileService {
  static Future<String?> updatePassword(String userId, String oldPassword, String newPassword, String token) async {
    final apiUrl = 'http://102.219.179.156:8082/user/$userId/password';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return 'Password updated successfully';
      } else {
        return jsonDecode(response.body)['error'] ?? 'Failed to update password';
      }
    } catch (e) {
      return 'Error updating password: $e';
    }
  }

  static Future<String?> sendVerificationCode(String userId, String oldEmail, String newEmail, String token) async {
    final apiUrl = 'http://102.219.179.156:8082/user/email/sendVerificationCode';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'userId': userId,
          'oldEmail': oldEmail,
          'newEmail': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        return 'Verification code sent successfully';
      } else {
        return jsonDecode(response.body)['error'] ?? 'Failed to send verification code';
      }
    } catch (e) {
      return 'Error sending verification code: $e';
    }
  }

  static Future<String?> changeEmail(String userId, String oldEmail, String newEmail, String verificationCode, String token) async {
    final apiUrl = 'http://102.219.179.156:8082/user/email/changeEmail';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'userId': userId,
          'oldEmail': oldEmail,
          'newEmail': newEmail,
          'verificationCode': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        return 'Email changed successfully';
      } else {
        return jsonDecode(response.body)['error'] ?? 'Failed to change email';
      }
    } catch (e) {
      return 'Error changing email: $e';
    }
  }
}
