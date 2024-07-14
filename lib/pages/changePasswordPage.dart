import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/services/editProfile_service.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  int _currentStep = 0;

  Future<String?> _getToken() async {
    try {
      // Retrieve the token from storage
      final token = await _storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<void> _updatePassword() async {
    try {
      final token = await _getToken();
      if (token != null) {
        // Decode the token to extract the user ID
        final Map<String, dynamic> payload = Jwt.parseJwt(token);
        final String userId = payload['id'].toString(); // Ensure userId is a string

        // Get the old and new passwords from text controllers
        final String oldPassword = _oldPasswordController.text;
        final String newPassword = _newPasswordController.text;

        // Call the service to update the password
        final result = await EditProfileService.updatePassword(userId, oldPassword, newPassword, token);

        // Show SnackBar with result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ?? 'Password updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear text controllers
        _oldPasswordController.clear();
        _newPasswordController.clear();

        // Reset the stepper
        setState(() {
          _currentStep = 0;
        });
      }
    } catch (e) {
      print('Error updating password: $e');
      // Show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password'),
          backgroundColor: Colors.red,
        ),
      );

      // Clear text controllers
      _oldPasswordController.clear();
      _newPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Changer Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900], // Couleur de la barre de navigation en haut (bleu foncé)
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Ajout de l'icône de retour
          onPressed: () {
            Navigator.pop(context); // Retour à la page précédente
          },
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 1) {
            // Update password
            _updatePassword();
          } else {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          setState(() {
            _currentStep--;
          });
        },
        steps: [
          Step(
            title: Text('Enter Old Password'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Old Password'),
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                ),
              ],
            ),
          ),
          Step(
            title: Text('Enter New Password'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Password'),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
