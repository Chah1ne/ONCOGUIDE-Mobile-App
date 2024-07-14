import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:patient_app/pages/account.dart';
import 'package:patient_app/pages/detail_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'constants.dart';
import '../widgets/bottom_navigation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patient_app/services/notifications_service.dart'; // Import NotificationService

class EducationPage extends StatefulWidget {
  @override
  _EducationPageState createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final storage = FlutterSecureStorage();
  List<dynamic> educationCards = [];

  // Initialize NotificationService
  final NotificationService _notificationService = NotificationService();

  // Initialize notifications list
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchEducationCards();
    // Fetch initial notifications and listen for updates
    fetchNotifications();
    // Set up the socket connection for notifications
    _notificationService.initSocket();
    // Listen to incoming notifications using the stream
    _notificationService.notificationsStream.listen((List<String> newNotifications) {
      print('Received new notifications: $newNotifications');
      setState(() {
        notifications = newNotifications;
      });
    });
  }

  @override
  void dispose() {
    // Dispose notification service
    _notificationService.dispose();
    super.dispose();
  }

  Future<void> fetchEducationCards() async {
    try {
      final token = await storage.read(key: 'token');
      final Map<String, dynamic> payload = Jwt.parseJwt(token!);
      final userId = payload['id'];

      final response = await http.get(
        Uri.parse('http://102.219.179.156:8082/card-assignments/getUserCards?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          educationCards = json.decode(response.body);
        });
      } else {
        print('Failed to fetch education cards');
      }
    } catch (error) {
      print('Error fetching education cards: $error');
    }
  }

  Widget buildCardWidget(dynamic card) {
    return GestureDetector(
        onTap: () {
      // Open detail page on tap
      Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => DetailPage(cardDetails: card),
          ),
      );
        },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: <Widget>[
              Image.network(
                card['iconImage'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    card['name'],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      backgroundColor: gradientEndColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF0050AC),
        title: Text('Education', style: TextStyle(color: Colors.white)),
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

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.7],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Explore your educational cards',
                    style: TextStyle(
                      fontSize: 39.0,
                      fontWeight: FontWeight.w900,
                      color: titleTextColor,
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 300.0,
                    child: educationCards.length > 1 ? CarouselSlider.builder(
                      itemCount: educationCards.length,
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 0.8,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final card = educationCards[index];
                        return buildCardWidget(card);
                      },
                    ) : (educationCards.isNotEmpty ? Center(
                      child: buildCardWidget(educationCards.first),
                    ) : Center(
                      child: CircularProgressIndicator(),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
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

