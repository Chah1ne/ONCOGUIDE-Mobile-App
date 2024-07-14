import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/treatment_service.dart';
import 'SideEffectsPage.dart';
import 'account.dart';
import 'add_new_treatment_cards.dart';
import '../widgets/bottom_navigation.dart';
import 'package:patient_app/services/notifications_service.dart';
import 'chatPatient.dart';


final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService notificationService = NotificationService();
  List<String> notifications = [];
  int totalCures = 0;
  double progressPercentage = 0.0;
  String progressText = '';
  String patientName = '';
  String patientSurname = '';
  String nextSessionMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchNextSession();
    // Fetch initial notifications and listen for updates
    fetchNotifications();

    // Set up the socket connection
    notificationService.initSocket();

    // Listen to incoming notifications using the stream
    notificationService.notificationsStream.listen((List<String> newNotifications) {
      print('Received new notifications: $newNotifications');
      setState(() {
        notifications = newNotifications;
      });
    });
  }

  Future<void> _initializeData() async {
    await _fetchTreatmentProgress();
    await _fetchPatientNameAndSurname();
  }

  Future<void> fetchNotifications() async {
    try {
      final token = await _getToken();
      final userId = Jwt.parseJwt(token!)['id'];
      final List<String> fetchedNotifications = await notificationService.fetchNotifications(userId);
      setState(() {
        notifications = fetchedNotifications;
      });
      print('Fetched notifications: $fetchedNotifications');
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }
  @override
  void dispose() {
    notificationService.dispose();
    super.dispose();
  }

  Future<void> _fetchTreatmentProgress() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final userId = Jwt.parseJwt(token)['id'];
        final treatmentService = TreatmentService();
        final treatmentProgress = await treatmentService.fetchTreatmentProgress(userId, token);
        setState(() {
          totalCures = treatmentProgress['totalCures'];
          // Check if progressPercentage is a string before parsing
          if (treatmentProgress['progressPercentage'] is String) {
            progressPercentage = double.parse(treatmentProgress['progressPercentage']);
          } else {
            // Handle the case if progressPercentage is already a double or another type
            // You may choose to set a default value or handle it differently based on your requirements
            // For example:
            progressPercentage = (treatmentProgress['progressPercentage'] ?? 0).toDouble();
          }
          progressText = treatmentProgress['progressText'];
        });
      } else {
        print('Token not available');
      }
    } catch (e) {
      print('Error fetching treatment progress: $e');
    }
  }

  Future<String?> _getToken() async {
    try {
      final token = await storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<void> _fetchPatientNameAndSurname() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final userId = Jwt.parseJwt(token)['id'];
        final response = await http.get(
            Uri.parse('http://102.219.179.156:8082/user/getNomPrenomPatient/$userId')
        );
        if (response.statusCode == 200) {
          final patientData = json.decode(response.body);
          setState(() {
            patientName = patientData['nom'];
            patientSurname = patientData['prenom'];
          });
        } else {
          throw Exception('Failed to load patient name and surname');
        }
      } else {
        print('Token not available');
      }
    } catch (error) {
      print('Error fetching patient name and surname: $error');
    }
  }

  Future<void> _fetchNextSession() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final userId = Jwt.parseJwt(token)['id'];
        final response = await http.get(
            Uri.parse('http://102.219.179.156:8082/products/getnextsession/$userId')
        );
        if (response.statusCode == 200) {
          final nextSessionData = json.decode(response.body);
          // Check if nextSessionData contains a message indicating no next session
          if (nextSessionData.containsKey('message')) {
            setState(() {
              nextSessionMessage = nextSessionData['message'];
            });
          } else {
            // Extract and process next session data here
            final startDate = nextSessionData['startDate'];
            // Extract only the date part
            final dateOnly = DateFormat('yyyy-MM-dd').format(DateTime.parse(startDate));
            setState(() {
              nextSessionMessage = 'Your next session is scheduled for $dateOnly';
            });

          }
        } else {
          throw Exception('Failed to load next session');
        }
      } else {
        print('Token not available');
      }
    } on http.ClientException catch (_) {
      // Handle exception 404 here
      setState(() {
        nextSessionMessage = 'Pas de prochaine séance pour le moment';
      });
    } catch (error) {
      print('Error fetching next session: $error');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Home', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_active, color: Colors.white),
                if (notifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notifications.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              // Show notifications under the icon when tapped
              showNotificationsList(context);
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$patientName $patientSurname',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: progressPercentage > 0
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Chimiothérapie Treatment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.blue,
                        letterSpacing: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                strokeWidth: 12,
                                value: progressPercentage / 100,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  progressText,
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Progress',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Total Cures: $totalCures',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),
                    // Display the next session message
                    if (nextSessionMessage.isNotEmpty) Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(maxWidth: 900), // Réduire la largeur du conteneur
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              nextSessionMessage,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis, // Tronquer le texte s'il dépasse la largeur
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white, // Fond blanc
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 2), // Bordure bleue
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SideEffectsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Fond transparent
                          elevation: 0, // Supprimer l'ombre
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Do you have any side effects after your last session?',
                            style: TextStyle(color: Colors.blue[900]), // Texte bleu
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white, // Fond blanc
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 2), // Bordure bleue
                      ),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPatientPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Fond transparent
                          elevation: 0, // Supprimer l'ombre
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Contact the doctor',
                            style: TextStyle(color: Colors.blue[900]), // Texte bleu
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No Treatment available for you 🤗'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10), // Ajoutez un espace entre les autres conteneurs et le bouton "Add New Treatment"

              Center( // Ajoutez le widget Center pour centrer le bouton
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewTreatmentCards()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Add New Treatment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped, add logic if needed
        },
      ),
    );
  }


// Function to show notifications in a list under the icon
  void showNotificationsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Height to limit the size of the modal and allow scrolling
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: notifications.isEmpty
                        ? [Text('No notifications available')]
                        : notifications.map((notification) {
                      return ListTile(
                        title: Text(
                          notification,
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 14, // Smaller font size
                          ),
                        ),
                        onTap: () {
                          // Show popup with the full notification when clicked
                          showNotificationPopup(context, notification);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Function to show a popup with the full notification
  void showNotificationPopup(BuildContext context, String notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text(notification),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

}