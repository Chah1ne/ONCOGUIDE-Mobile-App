import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String user;
  final int userId;
  final int otherUserId;
  final String userEmail;

  ChatScreen({required this.user, required this.userId, required this.otherUserId , required this.userEmail});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://102.219.179.156:8082/messages/${widget.userId}/${widget.otherUserId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final List<Map<String, dynamic>> messagesList = messagesJson.map((message) {
          final bool isCurrentUserMessage = message['sender'] == widget.user;
          message['isCurrentUserMessage'] = isCurrentUserMessage;
          return message as Map<String, dynamic>;
        }).toList();
        setState(() {
          messages = messagesList;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  void _sendMessage(String message) async {
    try {
      // Ajoutez le message temporaire avec l'utilisateur actuel
      Map<String, dynamic> sentMessage = {
        'sender': widget.userEmail,
        'message': message,
        'createdAt': DateTime.now().toString(), // Assuming server doesn't return createdAt
        'isCurrentUserMessage': widget.userId == widget.otherUserId, // Vérifiez si l'utilisateur actuel est l'expéditeur
      };
      setState(() {
        messages.add(sentMessage);
      });

      // Remove the sent message after a short delay to simulate temporary display
      Future.delayed(Duration(minutes: 3), () {
        setState(() {
          messages.remove(sentMessage);
        });
      });

      // Send the message to the server
      final response = await http.post(
        Uri.parse('http://102.219.179.156:8082/messages/create'),
        body: jsonEncode({
          'senderId': widget.userId,
          'receiverId': widget.otherUserId,
          'message': message,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        // Message successfully sent
        print('Message sent successfully');
      } else {
        // Failed to send message, remove the message from UI and display error message
        throw Exception('Failed to send message');
      }
    } catch (error) {
      print('Error sending message: $error');
      // Display an error toast or message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.user, style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // Retirer la propriété reverse: true
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isCurrentUserMessage = message['isCurrentUserMessage'];
                final messageAlignment = isCurrentUserMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end;
                final messageColor = isCurrentUserMessage ? Colors.blueGrey : Colors.blue[700];
                final createdAt = DateTime.parse(message['createdAt']);
                final hour = '${createdAt.hour}:${createdAt.minute}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: isCurrentUserMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: messageColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                            bottomLeft: isCurrentUserMessage ? Radius.circular(16.0) : Radius.circular(0),
                            bottomRight: isCurrentUserMessage ? Radius.circular(0) : Radius.circular(16.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),

                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: messageAlignment,
                          children: [
                            Text(
                              message['sender'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              message['message'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              hour,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      // Effacez le texte du TextField après l'envoi du message
                      _messageController.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
