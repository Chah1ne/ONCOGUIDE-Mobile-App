import 'package:flutter/material.dart';
import 'package:patient_app/services/api_client.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ApiClient apiClient = ApiClient();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();
  int _currentStep = 0;
  bool _verificationCodeSent = false;

  Future<void> _sendVerificationCode() async {
    try {
      final String email = _emailController.text;

      await apiClient.sendPasswordResetCode(email);

      setState(() {
        _verificationCodeSent = true;
        _currentStep++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code de vérification envoyé avec succés'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erreur lors de l\'envoi du code de vérification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du code de vérification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    try {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String verificationCode = _verificationCodeController.text;

      await apiClient.resetPassword(email, verificationCode, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mot de passe changé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      _emailController.clear();
      _passwordController.clear();
      _verificationCodeController.clear();

      setState(() {
        _verificationCodeSent = false;
        _currentStep = 0;
      });
    } catch (e) {
      print('Error changing Password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de changement de mot de passe'),
          backgroundColor: Colors.red,
        ),
      );

      _emailController.clear();
      _passwordController.clear();
      _verificationCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),

      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            setState(() {
              _currentStep++;
            });
          } else if (_currentStep == 1) {
            _sendVerificationCode();
          } else if (_currentStep == 2) {
            _changePassword();
          }
        },
        steps: [
          Step(
            title: Text('Enter your email associated with your account'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email'),
                TextField(controller: _emailController),
              ],
            ),
          ),
          Step(
            title: Text('Enter your new password'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Password'),
                TextField(controller: _passwordController),
              ],
            ),
          ),
          Step(
            title: Text('Enter verification code'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification code'),
                TextField(controller: _verificationCodeController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
