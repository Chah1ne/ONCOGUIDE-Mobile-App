import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/services/editProfile_service.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  TextEditingController _oldEmailController = TextEditingController();
  TextEditingController _newEmailController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  int _currentStep = 0;
  bool _verificationCodeSent = false;

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

  Future<void> _sendVerificationCode() async {
    try {
      final token = await _getToken();
      if (token != null) {
        // Decode the token to extract the user ID
        final Map<String, dynamic> payload = Jwt.parseJwt(token);
        final String userId = payload['id'].toString(); // Ensure userId is a string

        // Get the old and new emails from text controllers
        final String oldEmail = _oldEmailController.text;
        final String newEmail = _newEmailController.text;

        // Call the service to send verification code to the old email
        final result = await EditProfileService.sendVerificationCode(userId, oldEmail, newEmail, token);

        setState(() {
          _verificationCodeSent = true;
          _currentStep++;
        });

        // Show SnackBar with result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ?? 'Verification code sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error sending verification code: $e');
      // Show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeEmail() async {
    try {
      final token = await _getToken();
      if (token != null) {
        // Decode the token to extract the user ID
        final Map<String, dynamic> payload = Jwt.parseJwt(token);
        final String userId = payload['id'].toString(); // Ensure userId is a string

        // Get the old email, new email, and verification code from text controllers
        final String oldEmail = _oldEmailController.text;
        final String newEmail = _newEmailController.text;
        final String verificationCode = _verificationCodeController.text;

        // Call the service to change email after verifying code
        final result = await EditProfileService.changeEmail(userId, oldEmail, newEmail, verificationCode, token);

        // Show SnackBar with result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ?? 'Email changed successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear text controllers
        _oldEmailController.clear();
        _newEmailController.clear();
        _verificationCodeController.clear();

        // Reset the stepper
        setState(() {
          _verificationCodeSent = false;
          _currentStep = 0;
        });
      }
    } catch (e) {
      print('Error changing email: $e');
      // Show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing email'),
          backgroundColor: Colors.red,
        ),
      );

      // Clear text controllers
      _oldEmailController.clear();
      _newEmailController.clear();
      _verificationCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Changer Email',
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
          if (_currentStep == 0) {
            // Don't do anything, let the user proceed to the next step
            setState(() {
              _currentStep++;
            });
          } else if (_currentStep == 1) {
            // Send verification code
            _sendVerificationCode();
          } else if (_currentStep == 2) {
            // Verify and change email
            _changeEmail();
          }
        },
        steps: [
          Step(
            title: Text('Enter Old Email'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Old Email'),
                TextField(controller: _oldEmailController),
              ],
            ),
          ),
          Step(
            title: Text('Enter New Email'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Email'),
                TextField(controller: _newEmailController),
              ],
            ),
          ),
          Step(
            title: Text('Enter Verification Code'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Code'),
                TextField(controller: _verificationCodeController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
