import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:patient_app/pages/SideEffectsPage.dart';
import 'package:patient_app/pages/account.dart';
import 'package:patient_app/pages/add_new_treatment.dart';
import 'package:patient_app/pages/add_new_treatment_cards.dart';
import 'package:patient_app/pages/calendar_page.dart';
import 'package:patient_app/pages/chatDoctor.dart';
import 'package:patient_app/pages/education.dart';
import 'package:patient_app/pages/home.dart';
import 'package:patient_app/pages/journey.dart';
import 'package:patient_app/pages/side_effects_list.dart';
import 'package:patient_app/pages/signin.dart';
import 'package:patient_app/pages/signup.dart';
import 'package:patient_app/pages/welcome1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASQII',
      debugShowCheckedModeBanner: false, // Retirer la bannière de débogage
      initialRoute: '/',
      routes: {
        '/': (context) => MainSignInSignUpPage(),
        '/home': (context) => HomePage(),
        //'/signin': (context) => SignInPage(), // Ajoutez cette ligne
        //'/signup': (context) => SignUpPage(), // Ajoutez cette ligne
        '/calendar': (context) => CalendarPage(),
        '/chat': (context) => ChatPage(),
        '/education': (context) => EducationPage(),
        '/journey': (context) => JourneyPage(),
        '/add_new_treatment_cards': (context) => AddNewTreatmentCards(),
        '/add_new_treatment': (context) => AddNewTreatmentPage(),
        '/account' : (context) => AccountPage(),
        '/side_effects_list' : (context) => SideEffectsListPage(),
        '/side_effects' : (context) => SideEffectsPage(),
      },
    );
  }
}

class MainSignInSignUpPage extends StatelessWidget {
  Future<bool> isLoggedIn() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('ASQII'),
            ),
            body: SignInPage(),
          );
        } else {
          return CircularProgressIndicator(); // You can replace this with a loading indicator if needed
        }
      },
    );
  }
}
