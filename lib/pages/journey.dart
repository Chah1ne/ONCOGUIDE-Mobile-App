import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/treatment_service.dart';
import '../widgets/bottom_navigation.dart';
import 'account.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/services/notifications_service.dart'; // Import NotificationService

final storage = FlutterSecureStorage();

class JourneyPage extends StatefulWidget {
  @override
  _JourneyPageState createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  final NotificationService _notificationService = NotificationService(); // Initialize NotificationService
  List<String> notifications = []; // Initialize notifications list

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch initial notifications and listen for updates
    _notificationService.initSocket(); // Set up the socket connection for notifications
    _notificationService.notificationsStream.listen((List<String> newNotifications) {
      print('Received new notifications: $newNotifications');
      setState(() {
        notifications = newNotifications;
      });
    }); // Listen to incoming notifications using the stream
  }

  @override
  void dispose() {
    _notificationService.dispose(); // Dispose notification service
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    try {
      final token = await storage.read(key: 'token');
      final userId = Jwt.parseJwt(token!)['id'];
      final List<String> fetchedNotifications = await _notificationService.fetchNotifications(userId);
      setState(() {
        notifications = fetchedNotifications;
      });
      print('Fetched notifications: $fetchedNotifications');
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Couleur de la barre de navigation en haut (bleu foncé)
        title: Text('Journey', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white), // Icône de profil grise
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
              showNotificationsList(context); // Show notifications under the icon when tapped
            },
          )
        ],
      ),
      body: JourneyContent(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 4,
        onTabTapped: (index) {
          // Handle bottom navigation item tapped
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

class JourneyContent extends StatefulWidget {
  @override
  _JourneyContentState createState() => _JourneyContentState();
}

class _JourneyContentState extends State<JourneyContent> {
  int totalCures = 0;
  double progressPercentage = 0.0;
  String progressText = '';
  final List<String> motivationalMessages = [
    'Stay strong, every day is a step closer to recovery!',
    'Believe in yourself, you are stronger than you think!',
    'Keep fighting, brighter days are ahead!',
    'You are not alone in this journey, we are here to support you!',
    'You are a warrior, keep pushing forward!',
    'Your strength is greater than your struggle!',
    'Every setback is a setup for a comeback!',
    'Embrace the journey, no matter how hard it gets!',
    'Your courage inspires us all!',
    'You have got this!',
    'One day at a time, one step at a time!',
    'You are resilient, keep persevering!',
    'Focus on progress, not perfection!',
    'Difficult roads often lead to beautiful destinations!',
    'Your journey matters, and so do you!',
    // Add more motivational messages as needed
  ];

  @override
  void initState() {
    super.initState();
    _fetchTreatmentProgress();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Your Cancer Treatment Journey',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          AchievementCard(
            icon: Icons.favorite,
            achievement: 'Completed ${(progressPercentage).toStringAsFixed(0)} % chemotherapy traitement !',
          ),
          AchievementCard(
            icon: Icons.star,
            achievement: (progressPercentage/100) == 1
                ? 'Congratulations! You have completed your treatment!'
                : (progressPercentage/100) > 0.5
                ? 'You have made significant progress in your treatment!'
                : (progressPercentage/100) == 0.5
                ? 'You have reached halfway point of treatment!'
                : 'You still have a way to go in your treatment journey!',
          ),
          SizedBox(height: 20),
          MotivationalMessage(
            message: motivationalMessages[Random().nextInt(motivationalMessages.length)], // Select random motivational message
          ),
          SizedBox(height: 20),
          EmotionalSupportWidget(),
          SizedBox(height: 20),
          ShareExperienceWidget(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Start a quiz when the button is pressed
              startQuiz();
            },
            child: Text('Start Quiz'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void startQuiz() {
    // Simulate quiz completion with random responses for demonstration
    List<int> quizResponses = [
      Random().nextInt(4), // Replace with actual quiz responses
      Random().nextInt(4), // Replace with actual quiz responses
      Random().nextInt(4), // Replace with actual quiz responses
    ];

    // Call the method to handle quiz completion and provide personalized advice
    handleQuizCompletion(quizResponses);
  }

  void handleQuizCompletion(List<int> quizResponses) {
    // Simulate analysis of quiz responses and provide personalized advice
    // For demonstration, we'll just display a generic message based on the average response
    int averageResponse = (quizResponses.reduce((a, b) => a + b) / quizResponses.length).round();
    String adviceMessage;

    switch (averageResponse) {
      case 0:
        adviceMessage = 'You are doing great! Keep up the positive attitude!';
        break;
      case 1:
        adviceMessage = 'It seems like you could use some extra support. Remember, you are not alone!';
        break;
      case 2:
        adviceMessage = 'Remember to take care of yourself. Your well-being is important!';
        break;
      case 3:
        adviceMessage = 'It is okay to seek professional help if you are struggling. Your mental health matters!';
        break;
      default:
        adviceMessage = 'Keep pushing forward!';
    }

    // Display personalized advice on the UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(adviceMessage),
        duration: Duration(seconds: 5),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final IconData icon;
  final String achievement;

  const AchievementCard({
    Key? key,
    required this.icon,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          achievement,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MotivationalMessage extends StatelessWidget {
  final String message;

  const MotivationalMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}

class EmotionalSupportWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.favorite, color: Colors.red),
        title: Text(
          'Emotional Support',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Reach out to your support network for emotional strength and comfort.'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle emotional support tap
        },
      ),
    );
  }
}

class ShareExperienceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.share, color: Colors.green),
        title: Text(
          'Share Your Experience',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Share your journey and insights with others who may benefit.'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle share experience tap
        },
      ),
    );
  }
}
