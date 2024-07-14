import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:patient_app/pages/signin.dart';
import 'package:patient_app/pages/welcome1.dart';
import 'package:patient_app/services/api_client.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final ApiClient apiClient = ApiClient();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final storage = FlutterSecureStorage();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> storeToken(String token) async {
    try {
      await storage.write(key: 'token', value: token);
      print('Token successfully stored.');
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  void signUp(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        // Perform the sign-up
        final response = await apiClient.signUp(
          emailController.text,
          passwordController.text,
        );

        // If sign-up is successful, log in
        print('Inscription réussie: $response');

        // Perform the login using the provided credentials
        final loginResponse = await apiClient.signIn(
          emailController.text,
          passwordController.text,
        );

        // Extract the token from the login response
        final token = loginResponse['token'];
        print('Connexion réussie avec le token: $token');

        // Store the token
        await storeToken(token);

        // Navigate to the welcome page
        Navigator.push(context, MaterialPageRoute(builder: (context) => Welcome1Page()));
      } catch (e) {
        print('Erreur lors de l\'inscription: $e');
      }
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
                      builder: (BuildContext context, double value, Widget? child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Sign Up Form
              Form(
                key: formKey,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$").hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
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
                            obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => signUp(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sign In Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Text(
                    'Already have an account ? Log in.',
                    style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
