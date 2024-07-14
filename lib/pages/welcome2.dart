import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/pages/welcome3.dart';

class Welcome2Page extends StatelessWidget {
  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    try {
      // Retrieve the token from storage
      final token = await storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff115995), Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ID Unique',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        'Please remember to take note of your unique ID after registering in the application',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50.0),
                      FutureBuilder<String?>(
                        future: _getToken(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Text(
                                'Error fetching user ID',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                ),
                              );
                            } else if (snapshot.data != null) {
                              String userId = Jwt.parseJwt(snapshot.data!)['id'].toString();
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Your User ID:',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userId,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          // Copy the identification number to the clipboard
                                          Clipboard.setData(ClipboardData(text: userId));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('User ID copied'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: Icon(Icons.content_copy),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                      SizedBox(height: 30.0),
                      NextButton(),
                      SizedBox(height: 20.0),
                      PageIndicator(),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Welcome3Page()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      ),
      child: Text(
        'Next',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '2/3',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
