// notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

class NotificationService {
  late io.Socket socket;
  late StreamController<List<String>> _notificationsController;
  List<String> _currentNotifications = [];

  NotificationService() {
    _notificationsController = StreamController<List<String>>.broadcast();
  }

  void initSocket() {
    // Replace 'http://your-backend-url' with your actual backend URL
    socket = io.io('http://102.219.179.156:8082', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('newNotification', (data) {
      // Handle incoming notifications
      print('Received notification: ${data['message']}');
      final List<String> newNotifications = [data['message']];
      _currentNotifications = [..._currentNotifications, ...newNotifications];
      _notificationsController.add(_currentNotifications);
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void sendNotification(String message) {
    if (!_notificationsController.isClosed) {
      socket.emit('notification', {'message': message});
    } else {
      print('Stream controller is closed. Unable to send notification.');
    }
  }

  Stream<List<String>> get notificationsStream => _notificationsController.stream;

  Future<List<String>> fetchNotifications(int userId) async {
    final Uri uri = Uri.parse('http://102.219.179.156:8082/notif/getAllNotificationsForUser/$userId');
    final http.Client client = http.Client();

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = List.from(json.decode(response.body));
        List<String> notifications = data.map((item) => item['message'].toString()).toList();
        _currentNotifications = notifications;
        _notificationsController.add(_currentNotifications);
        return notifications;
      } else {
        throw Exception('Failed to load notifications');
      }
    } finally {
      client.close();
    }
  }

  void dispose() {
    _notificationsController.close();
  }
}
