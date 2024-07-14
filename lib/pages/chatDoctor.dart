import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/DoctorBottom_navigation.dart';
import 'account.dart';
import 'package:patient_app/pages/ChatScreen.dart';
import '../widgets/bottom_navigation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:patient_app/services/notifications_service.dart'; // Import NotificationService


final storage = FlutterSecureStorage();

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> connectedUsers = [];
  int userId = 0;
  TextEditingController emailController = TextEditingController();
  String? userEmail;
  // Initialize NotificationService
  final NotificationService _notificationService = NotificationService();

  // Initialize notifications list
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchConnectedUsers();
    _getUserEmail();
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


  Future<void> fetchNotifications() async {
    try {
      final token = await _getToken();
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

  Future<void> fetchConnectedUsers() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final decodedToken = Jwt.parseJwt(token);
        final userIdFromToken = decodedToken['id'];
        setState(() {
          userId = userIdFromToken;
        });
        final response = await http.get(
            Uri.parse('http://102.219.179.156:8082/messages/$userIdFromToken'));
        if (response.statusCode == 200) {
          final List<dynamic> usersJson = json.decode(response.body);
          final List<Map<String, dynamic>> usersList =
          usersJson.map((user) => user as Map<String, dynamic>).toList();
          for (var user in usersList) {
            final lastMessageResponse = await http.get(Uri.parse(
                'http://102.219.179.156:8082/messages/last-message/$userIdFromToken/${user['id']}'));
            if (lastMessageResponse.statusCode == 200) {
              final lastMessageJson = json.decode(lastMessageResponse.body);
              final lastMessage = lastMessageJson as Map<String, dynamic>;
              user['lastMessage'] = lastMessage;
            }
          }
          setState(() {
            connectedUsers = usersList;
          });
        } else {
          throw Exception('Failed to load connected users');
        }
      } else {
        print('Token not available');
      }
    } catch (error) {
      print('Error fetching connected users: $error');
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

  Future<void> _getUserEmail() async {
    try {
      final token = await _getToken();
      if (token != null) {
        final decodedToken = Jwt.parseJwt(token);
        final email = decodedToken['email'];
        setState(() {
          userEmail = email;
        });
      }
    } catch (error) {
      print('Error getting user email: $error');
    }
  }

  Future<void> addContact(String receiverEmail) async {
    try {
      final token = await _getToken();
      if (token != null) {
        final decodedToken = Jwt.parseJwt(token);
        final userIdFromToken = decodedToken['id'];

        final response = await http.post(
          Uri.parse('http://102.219.179.156:8082/messages/add-contact'),
          body: jsonEncode({
            'senderId': userIdFromToken,
            'receiverEmail': receiverEmail,
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          fetchConnectedUsers();
          Fluttertoast.showToast(
            msg: 'Contact ajouté avec succès! Email: $receiverEmail',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          throw Exception('Failed to add contact');
        }
      } else {
        print('Token not available');
      }
    } catch (error) {
      print('Error adding contact: $error');
      Fluttertoast.showToast(
        msg: 'Erreur lors de l ajout du contact',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Couleur principale
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AccountPage()));
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
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: connectedUsers.length,
              itemBuilder: (context, index) {
                final user = connectedUsers[index];
                return GestureDetector(
                  onTap: () {
                    final otherUserId = user['id'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          user: user['email'],
                          userId: userId,
                          otherUserId: otherUserId,
                          userEmail: userEmail ?? '', // Passez l'email de l'utilisateur connecté
                        ),
                      ),
                    );

                  },
                  child: UserTile(
                    userEmail: user['email'],
                    lastMessage: user['lastMessage'],
                    onTap: () {
                      final otherUserId = user['id'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            user: user['email'],
                            userId: userId,
                            otherUserId: otherUserId,
                            userEmail: userEmail ?? '', // Passez l'email de l'utilisateur connecté
                          ),
                        ),
                      );

                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddContactDialog(
                onAddContact: addContact,
              );
            },
          );
        },
        child: Icon(Icons.person_add_alt_1_rounded,color: Colors.white,),
        backgroundColor: Color(0xFF2D68E7), // Couleur principale
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: 1,
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

class AddContactDialog extends StatefulWidget {
  final Function(String) onAddContact;

  AddContactDialog({required this.onAddContact});

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(30.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Add a contact',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 30.0),
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String enteredEmail = _emailController.text;
                  await widget.onAddContact(enteredEmail);
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade500,
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


class UserTile extends StatelessWidget {
  final String userEmail;
  final Map<String, dynamic>? lastMessage;
  final VoidCallback onTap;

  UserTile({required this.userEmail, required this.lastMessage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1), // Bordure noire
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Ombre légère
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Décalage de l'ombre
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.person, color: Colors.black),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red, // Couleur du médicament
                ),
                child: Center(
                  child: Icon(Icons.medical_services, color: Colors.white, size: 15), // Icône du médicament
                ),
              ),
            ),
          ],
        ),
      ),


      title: Text(
        userEmail,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D68E7), // Couleur principale
        ),
      ),
      subtitle: lastMessage != null
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${lastMessage!['message']} ✔',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${formatDateTime(lastMessage!['createdAt'])}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      )
          : null,
      onTap: onTap,
    );
  }

  String formatDateTime(String createdAt) {
    final dateTime = DateTime.parse(createdAt);
    final hour = '${dateTime.hour}'.padLeft(2, '0');
    final minute = '${dateTime.minute}'.padLeft(2, '0');
    return '$hour:$minute';
  }
}
