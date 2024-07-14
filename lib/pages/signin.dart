import 'package:flutter/material.dart';
import 'package:patient_app/pages/signup.dart';
import 'package:patient_app/pages/forgotPassword.dart'; // Add this import
import 'package:patient_app/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home.dart';
import 'side_effects_list.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final ApiClient apiClient = ApiClient();
  final storage = FlutterSecureStorage();
  bool obscurePassword = true;
  String jwt = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> storeToken(String token) async {
    try {
      await storage.write(key: 'token', value: token);
      jwt = token;
      print('Token successfully stored.');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  void signIn(BuildContext context) async {
    try {
      // Validation des champs d'e-mail et de mot de passe
      if (emailController.text.isEmpty) {
        throw Exception('EMPTY_EMAIL');
      }
      if (passwordController.text.isEmpty) {
        throw Exception('EMPTY_PASSWORD');
      }

      final response = await apiClient.signIn(
        emailController.text,
        passwordController.text,
      );

      final token = response['token'];
      print('Connexion réussie avec le token: $token');

      // Store the token
      await storeToken(token);
      if (jwt != null) {
        final role = Jwt.parseJwt(jwt)['role'];
        if (role == 'doctor') {
          // Navigate to the home page
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SideEffectsListPage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        }
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      // Afficher un message d'erreur approprié en fonction de l'erreur
      String errorMessage =
          'Une erreur s\'est produite lors de la connexion. Veuillez réessayer.';
      if (e.toString().contains('EMPTY_EMAIL')) {
        errorMessage = 'Please enter your email address.';
      } else if (e.toString().contains('EMPTY_PASSWORD')) {
        errorMessage = 'Please enter your password.';
      } else if (e.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Password is incorrect.';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage =
        'This email does not exist in our system. Please check your email or register for an account.';
      }

      // Afficher le message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated App Logo
              Center(
                child: Column(
                  children: [
                    // Replace this with your app logo image
                    Image.asset('assets/Logo.png', width: 150),
                    SizedBox(height: 50),
                    // Fade in animation for the app name
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 1000),
                      builder: (BuildContext context, double value,
                          Widget? child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Sign In Form
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Toggle password visibility
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => signIn(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Connection',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sign Up Link
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: Text(
                        'You do not have an account ? Register.',
                        style:
                        TextStyle(fontSize: 14, color: Colors.blue[900]),
                      ),
                    ),
                    SizedBox(height: 10), // Add some spacing
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()));
                      },
                      child: Text(
                        'Forgot your password?',
                        style:
                        TextStyle(fontSize: 14, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
