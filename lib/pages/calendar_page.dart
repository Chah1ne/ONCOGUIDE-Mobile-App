import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:patient_app/services/calendar_service.dart';
import 'package:patient_app/services/notifications_service.dart'; // Import NotificationService
import '../models/Product.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../widgets/bottom_navigation.dart';
import 'account.dart';

final storage = FlutterSecureStorage();

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<int, List<Product>> _groupedProducts = {};
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  Set<String> _uniqueStartDates = Set<String>();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Initialize CalendarService
  final CalendarService _calendarService = CalendarService();

  // Initialize NotificationService
  final NotificationService _notificationService = NotificationService();

  // Initialize notifications list
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _firstDay = DateTime(_focusedDay.year - 1);
    _lastDay = DateTime(_focusedDay.year + 1, 12, 31);
    _fetchProducts();

    // Fetch initial notifications and listen for updates
    fetchNotifications();

    // Set up the socket connection for notifications
    _notificationService.initSocket();

    // Listen to incoming notifications using the stream
    _notificationService.notificationsStream.listen((
        List<String> newNotifications) {
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

  Future<void> _fetchProducts() async {
    try {
      // Retrieve the token from storage
      final token = await _getToken();

      if (token != null) {
        // Decode the token to get the user ID
        final Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

        if (decodedToken.containsKey('id')) {
          final userId = decodedToken['id'];

          // Make the API request with the user ID and token in the headers
          final Map<int, List<Product>> groupedProducts = await _calendarService
              .fetchProducts(userId, token);

          groupedProducts.values.forEach((products) {
            products.forEach((product) {
              _uniqueStartDates.add(
                  product.startDate.toLocal().toString().split(' ')[0]);
            });
          });

          setState(() {
            _groupedProducts = groupedProducts;
          });
        } else {
          // Handle invalid or missing 'id' claim in the token
          print('Invalid or missing user ID in the token');
        }
      } else {
        // Handle token not available
        print('Token not available');
      }
    } catch (e) {
      print('Error fetching products: $e');
      // Handle error as needed
    }
  }

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

  Future<void> fetchNotifications() async {
    try {
      final token = await _getToken();
      final userId = Jwt.parseJwt(token!)['id'];
      final List<String> fetchedNotifications = await _notificationService
          .fetchNotifications(userId);
      setState(() {
        notifications = fetchedNotifications;
      });
      print('Fetched notifications: $fetchedNotifications');
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }


  Future<void> _showPopup(List<Product> products) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.only(top: 26.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cure Details',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.name}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Dose: ${product.dose}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Start Date: ${DateFormat('yyyy-MM-dd HH:mm')
                                      .format(product.startDate)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 14.0,
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        // Couleur de la barre de navigation en haut (bleu foncé)
        title: Text('Calendar', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          // Icône de profil grise
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AccountPage()));
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

      body: TableCalendar(
        calendarFormat: _calendarFormat,
        focusedDay: _focusedDay,
        firstDay: _firstDay,
        lastDay: _lastDay,
        selectedDayPredicate: (day) {
          String formattedDay = day.toLocal().toString().split(' ')[0];
          bool isSelected = _uniqueStartDates.contains(formattedDay);
          print('Selected Day: $day, IsSelected: $isSelected');
          return isSelected;
        },
        onDaySelected: (selectedDay, focusedDay) {
          String formattedSelectedDay = selectedDay.toLocal().toString().split(
              ' ')[0];
          List<Product> selectedProducts = [];

          _groupedProducts.values.forEach((products) {
            products.forEach((product) {
              if (product.startDate.toLocal().toString().split(' ')[0] ==
                  formattedSelectedDay) {
                selectedProducts.add(product);
              }
            });
          });

          if (selectedProducts.isNotEmpty) {
            _showPopup(selectedProducts);
          }
        },
        calendarStyle: CalendarStyle(
          // Customize calendar style here
          todayTextStyle: TextStyle(color: Colors.white),
          selectedTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.red),
          outsideTextStyle: TextStyle(color: Colors.grey),
          outsideDaysVisible: false,
          // Hide days outside current month
          holidayTextStyle: TextStyle(color: Colors.green),
          isTodayHighlighted: true,
          // Highlight today's date
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            // Light blue background for today
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          // Customize header style here
          titleTextStyle: TextStyle(fontSize: 20),
          formatButtonVisible: false, // Hide format button
          titleCentered: true,
        ),
      ),


      bottomSheet: _groupedProducts.isNotEmpty
          ? Container(
        decoration: BoxDecoration(
          color: Colors.white, // Couleur de fond blanche pour le conteneur
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
        child: ElevatedButton(
          onPressed: () {
            // Naviguer vers la page AddNewTreatmentCards lorsqu'on clique sur le bouton
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Chimiothérapie treatment available',
              // Changement du texte lorsque des données sont disponibles
              style: TextStyle(color: Colors.white),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            // Changement de la couleur du bouton en bleu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Ajouter une bordure arrondie au bouton
            ),
          ),
        ),
      )


          : Container(
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
            // Naviguer vers la page AddNewTreatmentCards lorsqu'on clique sur le bouton
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'No treatment available',
              style: TextStyle(color: Colors.white),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors
                .grey, // Nouvelle façon de définir la couleur de fond
          ),
        ),
      ),


      bottomNavigationBar: BottomNavigation(
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
          height: 300,
          // Height to limit the size of the modal and allow scrolling
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
