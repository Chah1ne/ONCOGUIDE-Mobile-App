import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/pages/NewEducationPage.dart';
import '../widgets/DoctorBottom_navigation.dart';
import 'AllEducationCardsPage.dart';
import 'account.dart'; // Import the education creation page
import 'package:patient_app/services/notifications_service.dart'; // Import NotificationService

final storage = FlutterSecureStorage();

class HomeEducation extends StatefulWidget {
  @override
  _HomeEducationState createState() => _HomeEducationState();
}

class _HomeEducationState extends State<HomeEducation> {
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
        backgroundColor: Colors.blue[900],
        title: Text('Dashboard Education', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountPage()),
            );
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
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewEducationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15.0), backgroundColor: Colors.blue[900],
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Create a new education card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllEducationCardsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15.0), backgroundColor: Colors.blue[900],
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'See all cards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: 2,
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
